extends Control

onready var rules_popup = $PopupRules


func _ready() -> void:
	# Reset network peer if have some
	Global.reset_peer()


func _on_LangSwitcher_pressed() -> void:
	var locale : String = TranslationServer.get_locale()
	
	if locale == 'ru':
		locale = 'en'
	else:
		locale = 'ru'
	
	TranslationServer.set_locale(locale)
	get_tree().reload_current_scene()


func _on_BtnPlay_pressed() -> void:
	Global.start_game()


func _on_BtnMulti_pressed() -> void:
	get_tree().change_scene("res://screens/Lobby/Lobby.tscn")


func _on_BtnRules_pressed() -> void:
	rules_popup.popup()


func _on_BtnCloseRules_pressed() -> void:
	rules_popup.visible = false
