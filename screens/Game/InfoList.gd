extends VBoxContainer

const CROWN_ICON : String = '[font=res://assets/fonts/Img_bitmapfont.tres][img=24]res://assets/img/crown.png[/img][/font]'

onready var info_label = $InfoLabel
onready var btn_done = $BtnBox/BtnDone
onready var btn_play_again = $BtnBox/GameEnd/BtnPlayAgain
onready var game_end_node = $BtnBox/GameEnd

var is_game_end : bool = false


func _ready() -> void:
	btn_done.visible = false
	
	update_text()
	
	Global.connect("tile_opened", self, "_on_tile_opened")
	Global.connect("player_moved", self, "_on_player_moved")
	Global.connect("game_end", self, "_on_game_end")


func _on_player_moved(is_open_tile : bool):
	update_text()


func _on_BtnDone_pressed() -> void:
	btn_done.visible = false
	Global.emit_signal("player_moved", true)
	
	if Global.is_multi:
		rpc('tile_placed')


func _on_tile_opened():
	btn_done.visible = true
	update_text()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and btn_done.visible == true:
		_on_BtnDone_pressed()


func _on_game_end(points : Vector2):
	print('GameEnd')
	var win_code : int = 0 # 0 - win all, 1 - first, 2 - second player
	
	is_game_end = true
	
	if points.x > points.y:
		win_code = 1
	elif points.x < points.y:
		win_code = 2
	elif points.x == points.y:
		win_code = Global.active_player_index + 1
	
	Global.disconnect("tile_opened", self, "_on_tile_opened")
	Global.disconnect("player_moved", self, "_on_player_moved")
	
	# Format nick
	var player_1 : String = tr('PLAYER') + ' 1 '
	var player_2 : String = tr('PLAYER') + ' 2 '
	
	
	
	info_label.clear()
	info_label.append_bbcode((
		player_1 + 
		('([color=#%s]%s[/color]) %s: ' % [Global.EARTH_COLOR, tr('EARTH'), tr('SCORE')]) + 
		str(points.x) + 
		(' - ' + CROWN_ICON if win_code == 0 or win_code == 1 else '')
	))
	info_label.newline()
	info_label.append_bbcode((
		player_2 + 
		('([color=#%s]%s[/color]) %s: ' % [Global.WATER_COLOR, tr('SEA'), tr('SCORE')]) +
		str(points.y) + 
		(' - ' + CROWN_ICON if win_code == 0 or win_code == 2 else '')
	))
	
	if Global.is_multi:
		btn_play_again.visible = false
	
	game_end_node.visible = true


func _on_BtnPlayAgain_pressed() -> void:
	Global.start_game()
	get_tree().reload_current_scene()


func _on_BtnToggleMarkers_pressed() -> void:
	Global.emit_signal("toggle_markers")


func _on_BtnHome_pressed() -> void:
	get_tree().change_scene("res://screens/Home/Home.tscn")


func update_text():
	if is_game_end == true:
		return
	
	var player_side_text : String = ''
	
	if Global.player.play_side == Global.TILE_TYPE.EARTH:
		player_side_text = '[color=#' + Global.EARTH_COLOR + ']' + tr('EARTH') + '[/color]'
	else:
		player_side_text = '[color=#' + Global.WATER_COLOR + ']' + tr('SEA') + '[/color]'
	
	# Update text
	info_label.clear()
	
	info_label.add_text('%s: %d' % [tr('TURN'), Global.turn])
	info_label.newline()
	info_label.newline()
	
	if Global.is_multi and Global.is_multi_player_turn():
		info_label.append_bbcode('%s (%s)' % [tr('YOUR_MOVE'), player_side_text])
	else:
		info_label.append_bbcode((
			tr('MOVE_OF') + ' ' +
			tr('PLAYER') + ' ' + 
			str(Global.active_player_index + 1) +
			' (' + player_side_text + ')'
		))
	info_label.newline()
	
	match Global.rotate_counter:
		0, 1:
			info_label.add_text(tr('ROTATION_PERFORMED') + ': ' + str(Global.rotate_counter))
		_:
			info_label.append_bbcode((
				tr('ROTATION_PERFORMED') + ': ' + 
				'[color=red]' + 
				str(Global.rotate_counter) + 
				'[/color]'
			))
			info_label.newline()
			info_label.append_bbcode('[color=red]' + tr('ROTATION_LIMIT_ALERT') + '[/color]')
	
	# Control notes
	info_label.newline()
	
	if btn_done.visible == true:
		info_label.add_text(tr('ROTATION_NOTE'))
	else:
		if Global.rotate_counter >= 2:
			info_label.add_text(tr('PLACE_NEW'))
		else:
			info_label.add_text(tr('PLACE_NEW_ROTATE'))
		info_label.newline()
		info_label.newline()
		info_label.append_bbcode((
			'[font=res://assets/fonts/TextNote.tres]' + 
			tr('PLACE_NOTE') +
			'[/font]'
		))
		info_label.newline()
		info_label.append_bbcode((
			'[font=res://assets/fonts/TextNote.tres]' + 
			tr('ROTATE_NOTE') +
			'[/font]'
		))


remote func tile_placed():
	Global.emit_signal("player_moved", true)
