class_name LobbyController
extends CanvasLayer

var Ip_Address: String
var Port: int

var player_info := { "name": "Default" }


func start_host() -> bool:
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(Port)
	if error != 0:
		printerr("Could not start server: ", error)
		return false
	multiplayer.multiplayer_peer = peer
	return true


func connect_to_server() -> bool:
	if Ip_Address == '':
		printerr("Invalid Ip Address")
		return false
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_client(Ip_Address, Port)
	if error != 0:
		printerr("Could not connect to server: ", error)
		return false
	multiplayer.multiplayer_peer = peer
	return true
