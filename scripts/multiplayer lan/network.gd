extends Node

const PORT = 7777
const MAX_PLAYERS = 2

var players = {}
var local_id: int = 0

signal player_connected(id)
signal player_disconnected(id)
signal player_ready_changed(id)
signal all_ready()

var _ping_start_time = {}
var _ping_timer := 0.0
const PING_INTERVAL = 2.0

func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)

# ─── Host ────────────────────────────────────────────────
func create_server():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_PLAYERS)
	multiplayer.multiplayer_peer = peer
	local_id = 1
	players[1] = { "name": "Player 1", "ping": 0, "ready": false }
	print("Servidor criado. Peer ID = 1")

func join_server(ip: String):
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, PORT)
	multiplayer.multiplayer_peer = peer

func _on_peer_connected(id: int):
	print("Peer conectou: ", id)
	if multiplayer.is_server():
		players[id] = { "name": "Player " + str(id), "ping": 0, "ready": false }
		emit_signal("player_connected", id)
		_sync_players.rpc_id(id, players)

func _on_peer_disconnected(id: int):
	players.erase(id)
	emit_signal("player_disconnected", id)

func _on_connected_to_server():
	local_id = multiplayer.get_unique_id()
	print("Conectado! Meu peer ID = ", local_id)

func _on_connection_failed():
	print("Falha na conexão")

@rpc("authority", "reliable")
func _sync_players(data: Dictionary):
	players = data

func set_ready(is_ready: bool):
	if multiplayer.is_server():
		if not 1 in players:
			players[1] = { "name": "Player 1", "ping": 0, "ready": false }
		players[1]["ready"] = is_ready
		emit_signal("player_ready_changed", 1)
		_check_all_ready()
	else:
		_send_ready.rpc_id(1, local_id, is_ready)

@rpc("any_peer", "reliable")
func _send_ready(peer_id: int, is_ready: bool):
	if not multiplayer.is_server():
		return
	players[peer_id]["ready"] = is_ready
	emit_signal("player_ready_changed", peer_id)
	_check_all_ready()

func _check_all_ready():
	var all = players.values().all(func(p): return p["ready"])
	if all and players.size() == MAX_PLAYERS:
		emit_signal("all_ready")

func start_game():
	if multiplayer.is_server():
		_load_game.rpc()

@rpc("authority", "call_local", "reliable")
func _load_game():
	get_tree().change_scene_to_file("res://scenes/multiplayer lan/MainMultiplayer.tscn")

func _process(delta):
	if not multiplayer.has_multiplayer_peer():
		return
	if multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		return
	if not multiplayer.is_server():
		return
	_ping_timer += delta
	if _ping_timer >= PING_INTERVAL:
		_ping_timer = 0.0
		_medir_ping.rpc()

@rpc("authority", "call_local")
func _medir_ping():
	_ping_start_time[multiplayer.get_unique_id()] = Time.get_ticks_msec()
	if not multiplayer.is_server():
		_pong.rpc_id(1)
	else:
		if 1 in players:
			players[1]["ping"] = 0
			emit_signal("player_ready_changed", 1)

@rpc("any_peer")
func _pong():
	var sender = multiplayer.get_remote_sender_id()
	if sender in _ping_start_time and sender in players:
		var ping = Time.get_ticks_msec() - _ping_start_time[sender]
		players[sender]["ping"] = ping
		emit_signal("player_ready_changed", sender)
