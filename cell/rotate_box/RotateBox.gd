extends HBoxContainer

signal rotate_to(to_right)

onready var left_btn = $LeftButton
onready var right_btn = $RightButton


func _on_LeftButton_pressed() -> void:
	emit_signal("rotate_to", false)


func _on_RightButton_pressed() -> void:
	emit_signal("rotate_to", true)


func _on_RotateBox_visibility_changed() -> void:
	if visible == false:
		left_btn.toggle_content(false)
		right_btn.toggle_content(false)
