extends Node
var peer := WebSocketMultiplayerPeer.new()
var players = {}
var player_order = []

signal player_connected(slot: int)

func _ready():
	pass

func iniciar():
	if not GameState.multiplayer_mode:
		return
	var err = peer.create_server(8080)
	if err != OK:
		print("Erro ao iniciar servidor")
		return
	peer.peer_connected.connect(_on_peer_connected)
	print("Servidor iniciado na porta 8080")

func _on_peer_connected(id: int):
	if id not in player_order:
		player_order.append(id)
		print("Novo jogador conectado, slot:", player_order.size())
		emit_signal("player_connected", player_order.size())

func _process(delta):
	if not GameState.multiplayer_mode:
		return
	peer.poll()

	while peer.get_available_packet_count() > 0:
		var sender = peer.get_packet_peer()
		var packet = peer.get_packet()
		var text = packet.get_string_from_utf8()
		var data = JSON.parse_string(text)
		if data == null:
			continue
		players[sender] = data
func get_input(slot: int) -> Dictionary:
	if slot >= player_order.size():
		return {"left": false, "right": false, "jump": false, "kick": false}
	var id = player_order[slot]
	return players.get(id, {"left": false, "right": false, "jump": false, "kick": false})

func get_player_count() -> int:
	return player_order.size()
