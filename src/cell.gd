extends Control

@onready var click_region : TextureButton = $ClickRegion
@onready var texture : AnimatedSprite2D = $Texture

var placed : bool = false
var grid : GridContainer

var player_class : Manager.CLASS

signal game_ended

func _ready() -> void:
	texture.visible = false
	# Assign the grid reference to the parent
	grid = self.get_parent()
	# Assign the player class to the one assigned by the Manager singleton
	player_class = Manager.assigned_player

func _on_click_region_button_down() -> void:
	# if it's the player's current turn, place cell and change turn to false
	if Manager.players[multiplayer.get_unique_id()]['turn']:
		_place_cell.rpc(multiplayer.get_unique_id())
		_switch_turns.rpc(multiplayer.get_unique_id())

@rpc("any_peer", "call_local")
func _place_cell(id : int):
	if grid.state == grid.GAME_STATE.PENDING:
		if not placed:
			texture.visible = true
			player_class = Manager.players[id]['kind']
			if player_class == Manager.CLASS.X:
				texture.play("X_triggered")
			elif player_class == Manager.CLASS.O:
				texture.play("O_triggered")
		placed = true
		
		click_region.set_deferred("disabled", true)
		
		# Check the grid
		grid.check_grid()

@rpc("any_peer", "call_local")
func _switch_turns(id : int) -> void:
	if id != 1:
		# id is the current player that made the move ._.
		Manager.players[id]['turn'] = false
		# since there's only 1 other player in the dict, anyone who isn't the player who clicked will start their turn
		for i in Manager.players:
			# TODO add and i != 1 in the dedicated server build for good measure
			if i != id:
				Manager.players[i]['turn'] = true
