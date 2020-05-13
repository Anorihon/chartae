extends Object
class_name PlayersManager

var players : Array = []


func _init() -> void:
	add_player()
	add_player()


func add_player():
	var player : Player = Player.new()

	# Set Player side to Sea if already have player
	if players.size() > 0:
		player.play_side = Global.TILE_TYPE.SEA

	players.append(player)


func get_player_by_index(index : int) -> Player:
	return players[index]


func update_local_flag(peer_id : int):
	for player in players:
		player.is_local = true if player.peer_id == peer_id else false
