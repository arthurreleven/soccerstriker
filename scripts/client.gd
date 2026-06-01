extends Node

var peer := WebSocketMultiplayerPeer.new()
var connected := false

func _ready():
	if not GameState.multiplayer_mode or GameState.is_host:
		return 
	var err = peer.create_client("ws://SEU_IP:8080")
	if err != OK:
		print("Erro ao conectar")
		return
	print("Conectando ao servidor...")

func _process(delta):
	if not GameState.multiplayer_mode:
		return
	peer.poll()

	# Detecta conexão estabelecida
	if not connected and peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		connected = true
		print("Conectado ao servidor!")

	if not connected:
		return

	var input = {
		"left":  Input.is_action_pressed("Left"),
		"right": Input.is_action_pressed("Right"),
		"jump":  Input.is_action_just_pressed("Jump"),
		"kick":  Input.is_action_just_pressed("Kick")
	}
	var json = JSON.stringify(input)
	peer.put_packet(json.to_utf8_buffer())
