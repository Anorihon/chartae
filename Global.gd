extends Node

signal player_moved(is_open_tile)
signal tile_opened()
signal game_end(points)
signal toggle_markers()

const EARTH_COLOR : String = 'd35e00'
const WATER_COLOR : String = '00abd3'

enum TILE_TYPE { EARTH, SEA }

var is_multi : bool = false
var players_manager : PlayersManager
var turn : int = 1
var active_player_index : int = 0
var player : Player setget ,get_player
var rotate_counter : int = 0 # Rotates in row
var info_msg : String


func _enter_tree() -> void:
	TranslationServer.set_locale('ru')


func _ready() -> void:
	players_manager = PlayersManager.new()
	print('IP: ', IP.get_local_addresses())
	connect("player_moved", self, "player_did_move")


func _unhandled_input(event: InputEvent) -> void:
	# Exit game on press Esc button
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()


func start_game(is_online : bool = false):
	if is_online == false:
		randomize()
	
	# Reset turn
	turn = 1
	active_player_index = 0
	is_multi = is_online
	
	get_tree().change_scene("res://screens/Game/Game.tscn")


func get_player() -> Player:
	return players_manager.get_player_by_index(active_player_index)


func player_did_move(is_open_tile : bool):
	if active_player_index == 1:
		turn += 1
	
	active_player_index += 1
	
	if active_player_index >= players_manager.players.size():
		active_player_index = 0
	
	# Update rotate counter
	if is_open_tile == false:
		rotate_counter += 1
	else:
		rotate_counter = 0


func reset_peer():
	if get_tree().has_network_peer():
		get_tree().network_peer = null


# Check is it multiplayer and current player (local) can do action
func is_multi_player_turn() -> bool:
	if is_multi == false:
		return true
	
	if !get_tree().has_network_peer():
		return false
	
	if get_player().is_local == true:
		return true
	
	return false
