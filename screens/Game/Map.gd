extends GridContainer

var matrix : Array = []
var cells : Array = []
var active_cell : Cell = null


func _enter_tree() -> void:
	# Fill matrix
	var rows : int = 3
	var cols : int = 3
	var cell_index : int = 0
	
	cells = get_children()
	
	for row in rows:
		var ar : Array = []
		
		# Add cols
		for col in cols:
			var cell = cells[cell_index]
			
			cell.position_index = Vector2(row, col)
			ar.append(cell)
			
			cell_index += 1
		
		matrix.append(ar) # Add rows


func _ready():
	# Load MapTile resources, contain sides info and texture
	var map_tiles_path : String = 'res://cell/map_tiles/MapTile_'
	var tiles_info : Array = []
	
	for i in 9:
		tiles_info.append( load(map_tiles_path + str(i) + '.tres') )
	
	# Set middle tile
	var center_cell : Cell = cells[4]
	var rand_num : int = rand_range(0, 3)
	
	center_cell.setup_tile( tiles_info.pop_front() )
	
	for i in rand_num:
		center_cell.rotate()
	
	center_cell.open_tile()
	
	if Global.is_multi == false or Global.is_multi_player_turn():
		center_cell.toggle_rotate_gui(true)
	
	# Shuffle tiles
	tiles_info.shuffle()
	
	for i in 9:
		# 4 = center
		if i == 4:
			continue
		
		var cell = cells[i]
		cell.setup_tile( tiles_info.pop_back() )
	
	# Setup and connect cells
	for cell in cells:
		var neighbors : Array = get_neighbor_cells(cell)
		
		cell.neighbors = neighbors
		
		cell.connect("pressed", self, "_on_cell_pressed", [cell])
		cell.connect("mouse_entered", self, "_on_cell_mouse_entered", [cell])
		cell.connect("mouse_exited", self, "_on_cell_mouse_exited", [cell])
		cell.connect("click_rotate_btn", self, "_on_cell_click_rotate_btn")
	
	# Connect
	Global.connect("player_moved", self, "_on_player_moved")
	
	# Init first move
	_on_player_moved(false)


func _on_player_moved(is_open_tile : bool):
	var opened_cells : int = 0
	
	active_cell = null
	
	for cell in cells:
		cell.toggle_plus_icon(false)
		cell.toggle_rotate_gui(false)
		
		if cell.is_open() == true:
			opened_cells += 1
			
			if (
				Global.rotate_counter < 2 and 
				(Global.is_multi == false or Global.is_multi_player_turn())
			):
				cell.toggle_rotate_gui(true)
		elif can_open_cell(cell):
			cell.toggle_plus_icon(true)
	
	# If all cells is open - game end
	if opened_cells == cells.size():
		game_end()


func _on_cell_pressed(cell : Cell):
	if can_open_cell(cell) == false:
		return
	
	active_cell = cell # Save ref on pressed cell
	
	for _cell in cells:
		_cell.toggle_rotate_gui(false)
		_cell.toggle_plus_icon(false)
	
	cell.open_tile()
	cell.toggle_rotate_gui(true)
	
	Global.emit_signal("tile_opened")
	
	if Global.is_multi:
		rpc("open_cell", cell.get_index())


func _on_cell_mouse_entered(cell : Cell):
	if can_open_cell(cell) == false:
		return
	
	cell.toggle_border_gui(true)


func _on_cell_mouse_exited(cell : Cell):
	cell.toggle_border_gui(false)


func _on_cell_click_rotate_btn(cell : Cell, to_right : bool):
	cell.rotate(to_right)
	
	if Global.is_multi:
		rpc('rotate_cell', cell.get_index(), to_right)
	
	if active_cell == null:
		Global.emit_signal("player_moved", false)


func _on_toggle_markers():
	for cell in cells:
		cell.toggle_markers()


func get_neighbor_cells(cell : Cell) -> Array:
	var _cells : Array = [null, null, null, null] # top right bottom left - cell
	var pos : Vector2 = cell.position_index
	
	# Set top cell
	if pos.x > 0:
		_cells[0] = matrix[pos.x - 1][pos.y]
	
	# Set right cell
	if pos.y < 2:
		_cells[1] = matrix[pos.x][pos.y + 1]
	
	# Set bottom cell
	if pos.x < 2:
		_cells[2] = matrix[pos.x + 1][pos.y]
	
	# Set left cell
	if pos.y > 0:
		_cells[3] = matrix[pos.x][pos.y - 1]
	
	return _cells


func can_open_cell(cell : Cell) -> bool:
	if (
		Global.is_multi_player_turn() == false or  
		active_cell != null or  
		cell.is_open() or  
		cell.have_opened_neighbor() == false
	):
		return false
	return true


func game_end():
	print('Game End')
	
	var points_earth : int = get_points(Global.TILE_TYPE.EARTH)
	var points_sea : int = get_points(Global.TILE_TYPE.SEA)
	
	# Disconnect play events
	for cell in cells:
		cell.toggle_rotate_gui(false)
		
		cell.disconnect("pressed", self, "_on_cell_pressed")
		cell.disconnect("mouse_entered", self, "_on_cell_mouse_entered")
		cell.disconnect("mouse_exited", self, "_on_cell_mouse_exited")
		cell.disconnect("click_rotate_btn", self, "_on_cell_click_rotate_btn")
	
	Global.disconnect("player_moved", self, "_on_player_moved")
	
	print('Points earth: ' + str(points_earth))
	print('Points sea: ' + str(points_sea))
	
	# Emit signal
	Global.emit_signal("game_end", Vector2(points_earth, points_sea))
	
	# Listen toggle points marker event
	Global.connect("toggle_markers", self, "_on_toggle_markers")


func get_points(check_type : int) -> int:
	var center_cell : Cell = cells[4] # Center or start cell
	var frontier : Array = []
	var checked : Array = [] # List with indexes of checked cells
	var points : int = 1
	
	# Reset cells connect
	for cell in cells:
		cell.connected_point = -1
	
	frontier.append(center_cell)
	checked.append(center_cell)
	
	# Update points marker for center cell
	center_cell.show_marker(check_type, points)
	
	while not frontier.empty():
		var current_cell : Cell = frontier.pop_back()
		
		for i in current_cell.neighbors.size():
			var next_cell : Cell = current_cell.neighbors[i]
			
			if next_cell == null or checked.has(next_cell):
				continue
			
			# Check connect
			if is_cell_connected(current_cell, next_cell, i, check_type):
				frontier.append(next_cell)
				checked.append(next_cell)
				points += 1
				
				next_cell.show_marker(check_type, points)
	
	return points


func is_cell_connected(
	main_cell : Cell, 
	other_cell : Cell, 
	pos_index : int, 
	check_type : int = Global.TILE_TYPE.EARTH, 
	is_start_cell : bool = false) -> bool:
	
	# Store valid side parts (main cell, other cell)
	var valid_parts : Vector2 = Vector2(-1, -1)
	
	match pos_index:
		0: # Top cell
			if (
				main_cell.sides[0] == check_type and 
				main_cell.sides[0] == other_cell.sides[5]
			):
				valid_parts.x = 0
				valid_parts.y = 5
			elif (
				main_cell.sides[1] == check_type and
				main_cell.sides[1] == other_cell.sides[4]
			):
				valid_parts.x = 1
				valid_parts.y = 4
		1: # Right cell
			if (
				main_cell.sides[2] == check_type and 
				main_cell.sides[2] == other_cell.sides[7]
			):
				valid_parts.x = 2
				valid_parts.y = 7
			elif (
				main_cell.sides[3] == check_type and
				main_cell.sides[3] == other_cell.sides[6]
			):
				valid_parts.x = 3
				valid_parts.y = 6
		2: # Bottom cell
			if (
				main_cell.sides[5] == check_type and 
				main_cell.sides[5] == other_cell.sides[0]
			):
				valid_parts.x = 5
				valid_parts.y = 0
			elif (
				main_cell.sides[4] == check_type and
				main_cell.sides[4] == other_cell.sides[1]
			):
				valid_parts.x = 4
				valid_parts.y = 1
		3: # Left cell
			if (
				main_cell.sides[7] == check_type and 
				main_cell.sides[7] == other_cell.sides[2]
			):
				valid_parts.x = 7
				valid_parts.y = 2
			elif (
				main_cell.sides[6] == check_type and
				main_cell.sides[6] == other_cell.sides[3]
			):
				valid_parts.x = 6
				valid_parts.y = 3
	
	if valid_parts.x >= 0 and valid_parts.y >= 0:
		# Check edges
		# If its main cell, dont need to check edges
		if main_cell.get_index() == 4:
			other_cell.connected_point = valid_parts.y
			return true
		
		var search_v1 : Vector2 = Vector2(valid_parts.x, main_cell.connected_point)
		var search_v2 : Vector2 = Vector2(main_cell.connected_point, valid_parts.x)
		
		for edge in main_cell.edges:
			if search_v1 == edge or search_v2 == edge:
				other_cell.connected_point = valid_parts.y
				return true
	
	return false


remote func rotate_cell(cell_index : int, to_right : bool):
	var cell : Cell = cells[cell_index]
	cell.rotate(to_right)
	
	if active_cell == null:
		print('Emit player_moved after remote rotate_cell()')
		Global.emit_signal("player_moved", false)


remote func open_cell(cell_index : int):
	var cell : Cell = cells[cell_index]
	
	active_cell = cell
	cell.open_tile()
