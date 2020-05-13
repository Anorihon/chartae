extends Object
class_name Player


var peer_id : int = 1
var play_side : int
var is_local : bool = false setget set_is_local # Flag for local player in multiplayer game


func set_is_local(val : bool):
	is_local = val
	print('Update is_local=%s for Player with pper_id=%s' % [is_local, peer_id])
