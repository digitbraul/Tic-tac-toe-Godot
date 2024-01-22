extends Control

@onready var game_grid = $GameGrid
@onready var turn_label = $TurnLabel
@onready var notification_label = $NotificationLabel


func _ready():
	RenderingServer.set_default_clear_color(Color.hex(0x252b44ff))
	
	notification_label.visible = false
	
	# prevent a repositioning bug by setting original offsets (they're anchored to the center anyway)
	$GridV.position = Vector2(36, 106)
	$GridH.position = Vector2(144, 106)
	
	# for the tweening animation
	for cell in game_grid.get_children():
		cell.set_deferred("modulate", Color.hex(0x00000000))
	
	# Change the turn_label text color according to the player kind
	if Manager.assigned_player == Manager.CLASS.X:
		turn_label.set_deferred("theme_override_colors/default_color", Color.hex(0xe43b44ff))
	elif Manager.assigned_player == Manager.CLASS.O:
		turn_label.set_deferred("theme_override_colors/default_color", Color.hex(0x0099dbff))
	
	# Connect to the state changed signal
	game_grid.state_changed.connect(_on_state_changed)

func _process(_delta):
	# if it's the current player turn, print it on screen
	# prevent crash when server accidentally disconnects (still a bug)
	if game_grid.state == game_grid.GAME_STATE.PENDING and multiplayer.get_unique_id() != 0:
		if not multiplayer.is_server():
			if Manager.players[multiplayer.get_unique_id()]['turn']:
				turn_label.visible = true
			else:
				turn_label.visible = false

func _input(event):
	if event.is_action_pressed("screen_tap") and game_grid.state != game_grid.GAME_STATE.PENDING:
		restart_game.rpc()

@rpc("any_peer", "call_local")
func restart_game():
	self.queue_free()
	var game_scene = load("res://src/game_screen.tscn").instantiate()
	get_tree().get_root().add_child(game_scene)

func _on_state_changed(state) -> void:
	print(state)
	handle_state_change(state)

# Called by animation player
func start_animation() -> void:
	var tween = get_tree().create_tween()
	for cell in game_grid.get_children():
		tween.tween_property(cell, "modulate", Color.hex(0xFFFFFFFF), 0.2).set_ease(Tween.EASE_IN_OUT)

func handle_state_change(state):
	turn_label.visible = true
	match state:
		game_grid.GAME_STATE.X_WON:
			turn_label.set_text("[rainbow freq=2.0 sat=0.5 val=0.4][center]X WON![/center]")
		game_grid.GAME_STATE.O_WON:
			turn_label.set_text("[rainbow freq=2.0 sat=0.5 val=0.4][center]O WON![/center]")
		game_grid.GAME_STATE.DRAW:
			turn_label.set_text("[rainbow freq=2.0 sat=0.5 val=0.4][center]DRAW![/center]")
	notification_label.visible = true
