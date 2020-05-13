extends Popup

onready var info_node = $Panel/CenterContainer/VBoxContainer/Info


func _ready() -> void:
	info_node.bbcode_text = tr('RULES_TEXT')


func _on_BtnClose_pressed() -> void:
	visible = false
