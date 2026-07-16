class_name LobbyManager
extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

var Ip_Address: String
var Port: int

var player_info := { "name": "Default" }
var players := { }


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)


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


@rpc("any_peer", "reliable")
func _register_player(new_player_info) -> void:
	var new_player_id = multiplayer.get_unique_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)


func _on_connected_ok() -> void:
	var peer_id := multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)


func _on_player_connected(id: int) -> void:
	_register_player.rpc_id(id, player_info)


func _on_player_disconnected(id: int) -> void:
	players.erase(id)
	player_disconnected.emit(id)
