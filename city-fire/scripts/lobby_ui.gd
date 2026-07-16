class_name LobbyUI
extends CanvasLayer

func _ready() -> void:
	Lobby.server_started.connect(_server_started)


func _server_started() -> void:
	pass


func _new_ip_submitted(new_text: String) -> void:
	var ip := new_text.left(new_text.find(":"))
	var port := new_text.right(new_text.find(":"))
	Lobby.Ip_Address = ip
	Lobby.Port = int(port)


func _player_info_submitted(new_text: String) -> void:
	Lobby.player_info['name'] = new_text


func _start_host_pressed() -> void:
	if Lobby.start_host():
		$UI/Vbox/Status/Label.text = 'Host running'
	else:
		$UI/Vbox/Status/Label.text = 'Host failed to start'


func _connect_pressed() -> void:
	if Lobby.connect_to_server():
		$UI/Vbox/Status/Label.text = 'Connected.'
	else:
		$UI/Vbox/Status/Label.text = 'Failed to connect'


func _start_game_pressed() -> void:
	pass
