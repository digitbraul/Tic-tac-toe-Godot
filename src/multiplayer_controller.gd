extends Control

@export var server_address = "192.168.1.30" # .30
@export var port : int = 6990

@onready var game_texture = $GameTexture
@onready var notification_label = $NotificationLabel
@onready var start_label = $StartLabel

var peer : ENetMultiplayerPeer
var game_started = false

func _ready():
	# set up multiplayer signals
	multiplayer.peer_connected.connect(player_connected)
	multiplayer.peer_disconnected.connect(player_disconnected)
	multiplayer.connected_to_server.connect(on_connected_to_server)
	multiplayer.connection_failed.connect(on_connection_failed)
	
	RenderingServer.set_default_clear_color(Color.hex(0x252b44ff))
	
	if "--server" in OS.get_cmdline_args():
		host_game()
	else:
		# Wait for a bit and trigger join
		await get_tree().create_timer(randf() + 0.5).timeout
		_join()

func _process(_delta):
	if Manager.players.size() > 1:
		# enable start game here
		start_label.set_text("[pulse][center]Tap screen to start![/center][/pulse]")

func _input(event):
	if event.is_action_pressed("screen_tap") and not game_started:
		start_game.rpc()

# Signal Callbacks
# called on server and clients
func player_connected(id : int) -> void:
	print("Player with ID ", id, " connected!")
	notification_label.set_text("Player " + str(id) + " connected!")

func player_disconnected(id : int) -> void:
	print("Player with ID ", id, " disconnected")

# called only on clients
func on_connected_to_server():
	send_info.rpc_id(1, multiplayer.get_unique_id())
	print("Connected to server!")

func on_connection_failed():
	print("Could not connect!")

# for inital testing ----------------------------------------
func host_game():
	peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(port, 3)
	if err != OK:
		print("Could not create host. Error: ", err)
		return
	
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for players...")
	
	# remove this line for dedicated server
	send_info(multiplayer.get_unique_id())

func _join() -> void:
	peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(server_address, port)
	
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)

@rpc("any_peer", "call_local", "reliable")
func start_game() -> void:
	game_started = true
	# Assign the kind to the current player (for them to become their respective kind)
	# check if the id isn't 1 for the dedicated server build
	print(multiplayer.get_unique_id())
	if multiplayer.get_unique_id() != 1:
		Manager.assigned_player = Manager.players[multiplayer.get_unique_id()]['kind']
	
		# X player will get the first turn
		if Manager.assigned_player == Manager.CLASS.X:
			Manager.players[multiplayer.get_unique_id()]['turn'] = true
		
	self.hide()
	var game_scene = load("res://src/game_screen.tscn").instantiate()
	get_tree().get_root().add_child(game_scene)

@rpc("any_peer")
func send_info(id : int) -> void:
	var kind : Manager.CLASS
	if not Manager.players.has(id) and id != 1:
		for i in Manager.players:
			if Manager.players[i]['kind'] == Manager.CLASS.X:
				kind = Manager.CLASS.O
			elif Manager.players[i]['kind'] == Manager.CLASS.O:
				kind = Manager.CLASS.X
		
		Manager.players[id] = {'kind' : kind, 'score' : 0, 'turn' : false}
	
	if multiplayer.is_server():
		for i in Manager.players:
			send_info.rpc(i)

