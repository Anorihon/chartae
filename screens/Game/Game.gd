extends Control

func _ready() -> void:
	if Global.is_multi:
		get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
		get_tree().connect("server_disconnected", self, "_server_disconnected")
		Global.connect("game_end", self, "_on_game_end")


func _player_disconnected(id):
	print('Player with peer id: %s disconnected' % id)
	terminate_multi_game()


func _server_disconnected():
	print('Server disconnected')
	terminate_multi_game()


func _on_game_end(points):
	get_tree().disconnect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().disconnect("server_disconnected", self, "_server_disconnected")


func terminate_multi_game():
	Global.info_msg = tr('TERMINATE_PEER_DISCONNECTED')
	get_tree().change_scene("res://screens/Lobby/Lobby.tscn")
