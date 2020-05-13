extends Control

const SERVER_PORT : int = 23023

enum STATE{MENU, WAIT_PLAYER, CONNECTING}

onready var menu_node = $Content/Menu
onready var onboarding_node = $Content/Onboarding
onready var onboarding_label = $Content/Onboarding/Label
onready var join_btn = $Content/Menu/VBoxContainer/BtnJoin
onready var ip_address_field = $Content/Menu/VBoxContainer/IPaddress
onready var info_dialog = $AcceptDialog

var screen_state : int = STATE.MENU setget screen_state_set


func _ready() -> void:
	self.screen_state = STATE.MENU
	
	# Setup localhost for fast connect in dev mode
	if OS.is_debug_build():
		ip_address_field.text = '127.0.0.1'
		join_btn.disabled = false
	
	# Show info popup if got message
	if !Global.info_msg.empty():
		show_info_popup(Global.info_msg)
	
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")


func _connected_fail():
	# Could not even connect to server; abort.
	network_fail()


func _server_disconnected():
	# Server kicked us; show error and abort.
	network_fail()


func _player_connected(id):
	var local_peer_id : int = get_tree().get_network_unique_id()
	
	# Called on both clients and server when a peer connects. Send my info to it.
	print('Own peer is %s and connected peer is: %s' % [local_peer_id, id])
#	rpc_id(id, "register_player", my_info)
	
	# Block new connections
	if get_tree().has_network_peer():
		get_tree().refuse_new_network_connections = true
	
	# Save connected player peer_id
	Global.players_manager.players[1].peer_id = id if id > 1 else local_peer_id
	Global.players_manager.update_local_flag(local_peer_id)
	
	if get_tree().get_network_unique_id() == 1:
		var random_seed = randi()
		rpc("prepare_to_start", random_seed)


func _on_BtnCreate_pressed() -> void:
	var peer = NetworkedMultiplayerENet.new()
	var err = peer.create_server(SERVER_PORT, 2)
	
	if err != OK:
		printerr('Error code %s on server create' % err)
		return 
	
	get_tree().set_network_peer(peer)
	
	self.screen_state = STATE.WAIT_PLAYER


func _on_BtnJoin_pressed() -> void:
	var peer = NetworkedMultiplayerENet.new()
	var err = peer.create_client(ip_address_field.text, SERVER_PORT)
	
	if err != OK:
		printerr('Error code %s on join' % err)
		return 
	get_tree().set_network_peer(peer)
	
	self.screen_state = STATE.CONNECTING


func _on_BtnBack_pressed() -> void:
	get_tree().change_scene("res://screens/Home/Home.tscn")


func _on_LineEdit_text_changed(new_text: String) -> void:
	if new_text.is_valid_ip_address():
		join_btn.disabled = false
	else:
		join_btn.disabled = true


func _on_BtnCancel_pressed() -> void:
	Global.reset_peer()
	
	self.screen_state = STATE.MENU


func screen_state_set(new_value):
	print('Trigger screen_state_set %d' % new_value)
	screen_state = new_value
	
	match new_value:
		STATE.MENU:
			onboarding_node.visible = false
			if get_tree().has_network_peer():
				get_tree().refuse_new_network_connections = false
		STATE.CONNECTING:
			onboarding_label.text = tr('CONNECTING')
			onboarding_node.visible = true
		STATE.WAIT_PLAYER:
			onboarding_label.text = tr('WAIT_PLAYER')
			onboarding_node.visible = true
	
	menu_node.visible = !onboarding_node.visible


func network_fail():
	show_info_popup(tr('CONNECTION_FAILED'))
	self.screen_state = STATE.MENU


func show_info_popup(message : String):
	info_dialog.dialog_text = message
	info_dialog.popup()


remotesync func prepare_to_start(random_seed : int) -> void:
	seed(random_seed)
	Global.start_game(true)
