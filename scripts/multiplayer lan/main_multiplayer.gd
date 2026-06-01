extends Node2D

@onready var player1 = $Player1
@onready var player2 = $Player2
@onready var ball    = $Ball

func _ready():
	if not multiplayer.has_multiplayer_peer():
		return

	if multiplayer.is_server():
		var ids = Network.players.keys()
		ids.sort()
		player1.set_multiplayer_authority(1)
		ball.set_multiplayer_authority(1)
		if ids.size() >= 2:
			player2.set_multiplayer_authority(ids[1])
	else:
		call_deferred("_set_client_authority")

func _set_client_authority():
	var my_id = multiplayer.get_unique_id()
	player1.set_multiplayer_authority(1)
	ball.set_multiplayer_authority(1)
	player2.set_multiplayer_authority(my_id)
	print("Cliente authority setada — Player2: ", player2.get_multiplayer_authority())
	
	print("=== AUTHORITY CHECK ===")
	print("Player2 authority: ", player2.get_multiplayer_authority())
	print("Meu ID: ", my_id)
	print("É server: ", multiplayer.is_server())
