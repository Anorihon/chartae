extends Button

onready var box_node = $Box


func _ready() -> void:
	toggle_content(false)


func _on_RotateButton_mouse_entered() -> void:
	toggle_content(true)


func _on_RotateButton_mouse_exited() -> void:
	toggle_content(false)


func toggle_content(is_visible : bool):
	box_node.visible = is_visible
