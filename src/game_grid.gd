extends GridContainer

enum GAME_STATE {X_WON, O_WON, DRAW, PENDING}
# Initialize game state to PENDING state
var state = GAME_STATE.PENDING

signal state_changed

func _ready() -> void:
	pass

func _process(delta) -> void:
	pass

func check_grid() -> void:
	# Check all the cells
	var countX : int = 0
	var countO : int = 0
	var non_empty_cell_count : int = 0
	
	# Check the rows and columns
	var cells = get_children()
	# Janky implementation with O(9^2) time for each iteration (sadge ._.)
	# ROWS
	# Check the top row
	for cell in cells:
		if cell.name.begins_with("T"):
			if cell.placed:
				if cell.player_class == Manager.CLASS.X:
					countX += 1
					if countX == 3:
						state = GAME_STATE.X_WON
						emit_signal("state_changed", state)
						return
				elif cell.player_class == Manager.CLASS.O:
					countO += 1
					if countO == 3:
						state = GAME_STATE.O_WON
						emit_signal("state_changed", state)
						return
	# Check the middle row
	countX = 0
	countO = 0
	for cell in cells:
		if cell.name.begins_with("M"):
			if cell.placed:
				if cell.player_class == Manager.CLASS.X:
					countX += 1
					if countX == 3:
						state = GAME_STATE.X_WON
						emit_signal("state_changed", state)
						return
				elif cell.player_class == Manager.CLASS.O:
					countO += 1
					if countO == 3:
						state = GAME_STATE.O_WON
						emit_signal("state_changed", state)
						return
	# Check the bottom row
	countX = 0
	countO = 0
	for cell in cells:
		if cell.name.begins_with("B"):
			if cell.placed:
				if cell.player_class == Manager.CLASS.X:
					countX += 1
					if countX == 3:
						state = GAME_STATE.X_WON
						emit_signal("state_changed", state)
						return
				elif cell.player_class == Manager.CLASS.O:
					countO += 1
					if countO == 3:
						state = GAME_STATE.O_WON
						emit_signal("state_changed", state)
						return
	
	# COLUMNS
	# Check the left column
	countX = 0
	countO = 0
	for cell in cells:
		if cell.name.ends_with("L"):
			if cell.placed:
				if cell.player_class == Manager.CLASS.X:
					countX += 1
					if countX == 3:
						state = GAME_STATE.X_WON
						emit_signal("state_changed", state)
						return
				elif cell.player_class == Manager.CLASS.O:
					countO += 1
					if countO == 3:
						state = GAME_STATE.O_WON
						emit_signal("state_changed", state)
						return
	# Check the middle column
	countX = 0
	countO = 0
	for cell in cells:
		if cell.name.ends_with("M"):
			if cell.placed:
				if cell.player_class == Manager.CLASS.X:
					countX += 1
					if countX == 3:
						state = GAME_STATE.X_WON
						emit_signal("state_changed", state)
						return
				elif cell.player_class == Manager.CLASS.O:
					countO += 1
					if countO == 3:
						state = GAME_STATE.O_WON
						emit_signal("state_changed", state)
						return
	# Check the right column
	countX = 0
	countO = 0
	for cell in cells:
		if cell.name.ends_with("R"):
			if cell.placed:
				if cell.player_class == Manager.CLASS.X:
					countX += 1
					if countX == 3:
						state = GAME_STATE.X_WON
						emit_signal("state_changed", state)
						return
				elif cell.player_class == Manager.CLASS.O:
					countO += 1
					if countO == 3:
						state = GAME_STATE.O_WON
						emit_signal("state_changed", state)
						return
	
	# The game also ends if all cells are non-empty (DRAW state)
	for cell in cells:
		if cell.placed:
			non_empty_cell_count += 1
	
	# Check both diagonals
	if cells[0].placed and cells[0].player_class == Manager.CLASS.X and cells[4].placed and cells[4].player_class == Manager.CLASS.X and cells[8].placed and cells[8].player_class == Manager.CLASS.X:
		state = GAME_STATE.X_WON
		emit_signal("state_changed", GAME_STATE.X_WON)
		return
	if cells[0].placed and cells[0].player_class == Manager.CLASS.O and cells[4].placed and cells[4].player_class == Manager.CLASS.O and cells[8].placed and cells[8].player_class == Manager.CLASS.O:
		state = GAME_STATE.O_WON
		emit_signal("state_changed", GAME_STATE.O_WON)
		return
	if cells[2].placed and cells[2].player_class == Manager.CLASS.X and cells[4].placed and cells[4].player_class == Manager.CLASS.X and cells[6].placed and cells[6].player_class == Manager.CLASS.X:
		state = GAME_STATE.X_WON
		emit_signal("state_changed", GAME_STATE.X_WON)
		return
	if cells[2].placed and cells[2].player_class == Manager.CLASS.O and cells[4].placed and cells[4].player_class == Manager.CLASS.O and cells[6].placed and cells[6].player_class == Manager.CLASS.O:
		state = GAME_STATE.O_WON
		emit_signal("state_changed", GAME_STATE.O_WON)
		return
	
	# Check if there's no more empty cells and end the game
	if non_empty_cell_count == 9:
		state = GAME_STATE.DRAW
		emit_signal("state_changed", GAME_STATE.DRAW)
		return
