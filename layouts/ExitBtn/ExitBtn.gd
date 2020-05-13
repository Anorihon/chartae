extends MarginContainer

const TWEEN_SCALE : Vector2 = Vector2(1.2, 1.2)

onready var tween = $Tween
onready var btn = $Button


func _on_Button_pressed() -> void:
	get_tree().quit()


func _on_Button_mouse_entered() -> void:
	animate_btn(true)


func _on_Button_mouse_exited() -> void:
	animate_btn(false)


func animate_btn(hover : bool):
	tween.remove_all()
	tween.interpolate_property(
		self, 
		"rect_scale", 
		(TWEEN_SCALE if hover == false else Vector2(1, 1)),
		(TWEEN_SCALE if hover == true else Vector2(1, 1)),
		.5, 
		Tween.TRANS_BACK, 
		Tween.EASE_OUT
	) 
	tween.start()
	yield(tween, "tween_completed")
