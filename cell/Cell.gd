extends Control
class_name Cell

signal click_rotate_btn(cell, to_right)

onready var tile = $Tile
onready var border_node = $SelectBorder
onready var rotate_box = $RotateBox
onready var plus_icon = $PlusIcon
onready var markers_node = $Markers
onready var earth_marker = $Markers/Earth
onready var earth_marker_label = $Markers/Earth/Label
onready var sea_marker = $Markers/Sea
onready var sea_marker_label = $Markers/Sea/Label
onready var tween = $Tween


var sides : Array
var edges : Array
var position_index : Vector2 # Index of position in cells matrix (row, col index - 0, 1)
var neighbors : Array
var connected_point : int = -1


func _ready() -> void:
	rotate_box.connect("rotate_to", self, "_on_click_rotate_btn")


func _on_click_rotate_btn(to_right : bool):
	if tween.is_active():
		return
	emit_signal("click_rotate_btn", self, to_right)


func rotate(to_right : bool = true):
	var ar_size : int = sides.size()
	var new_sides : Array = []
	
	if ar_size == 0:
		printerr('sides array is EMPTY!')
		return
	
	# Rotate texture
	tween.interpolate_property(
		tile, 
		"rect_rotation", 
		tile.rect_rotation,
		(tile.rect_rotation + 90 if to_right == true else tile.rect_rotation - 90), 
		.25, 
		Tween.TRANS_BACK, 
		Tween.EASE_OUT
	) 
	tween.start()
	yield(tween, "tween_completed")
	
	# Fill new rotated array
	new_sides.resize(ar_size)
	
	for i in ar_size:
		var next_ind : int = i
		
		next_ind = rotate_value(next_ind, to_right)
		
		# Append index to new sides array
		new_sides[next_ind] = sides[i]
	
	# Apply update
	sides = new_sides
	
	# Update edges
	for i in range(edges.size()):
		var edge : Vector2 = edges[i]
		edges[i] = Vector2(
			rotate_value(edge.x, to_right), 
			rotate_value(edge.y, to_right))


func setup_tile(tile_info : MapTile):
	tile.texture = tile_info.texture
	sides = tile_info.sides.duplicate()
	edges = tile_info.edges.duplicate()


func is_open() -> bool:
	return tile.visible


func have_opened_neighbor() -> bool:
	# Check open neighbors
	for cell in neighbors:
		if cell != null and cell.is_open():
			return true
	
	return false


func open_tile():
	toggle_border_gui(false)
	tile.visible = true


func toggle_rotate_gui(is_visible : bool):
	rotate_box.visible = is_visible


func toggle_border_gui(is_visible : bool):
	border_node.visible = is_visible


func toggle_plus_icon(is_visible : bool):
	plus_icon.visible = is_visible


func toggle_markers():
	markers_node.visible = !markers_node.visible


func show_marker(type : int, num : int):
	if type == Global.TILE_TYPE.EARTH:
		earth_marker.visible = true
		earth_marker_label.text = str(num)
	else:
		sea_marker.visible = true
		sea_marker_label.text = str(num)


static func rotate_value(num : int, to_right : bool) -> int:
	if to_right == true:
		num += 2
	else:
		num -= 2
	
	if num >= 8:
		num = num - 8
	if num < 0:
		num = 8 - abs(num)
	
	return num
