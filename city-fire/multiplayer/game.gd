class_name Game
extends Node2D

func _ready() -> void:
	Lobby.player_loaded.rpc_id(1)


func start_game() -> void:
	print("game is started")
