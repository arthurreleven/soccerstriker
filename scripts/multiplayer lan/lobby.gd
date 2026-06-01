extends Control

@onready var btn_comecar   = $Jogar
@onready var p1_name       = $Player1/Name
@onready var p1_ping       = $Player1/Ping
@onready var p1_status     = $Player1/Ok
@onready var p1_btn_pronto = $Player1/ButtonPronto

@onready var p2_name       = $Player2/Name
@onready var p2_ping       = $Player2/Ping
@onready var p2_status     = $Player2/Ok
@onready var p2_btn_pronto = $Player2/ButtonPronto1

var eu_estou_pronto = false

func _ready():
	btn_comecar.visible = multiplayer.is_server()
	btn_comecar.disabled = true

	_resetar_ui()

	Network.player_connected.connect(_on_player_connected)
	Network.player_disconnected.connect(_on_player_disconnected)
	Network.player_ready_changed.connect(_on_ready_changed)
	Network.all_ready.connect(_on_all_ready)

	_atualizar_todos()

func _resetar_ui():
	p1_name.text   = "Aguardando..."
	p1_ping.text   = "-- ms"
	p1_status.text = "Preparando"
	p1_status.modulate = Color.ORANGE

	p2_name.text   = "Aguardando..."
	p2_ping.text   = "-- ms"
	p2_status.text = "Preparando"
	p2_status.modulate = Color.ORANGE

func _atualizar_todos():
	var ids = Network.players.keys()
	ids.sort()

	_atualizar_player_ui(1, ids[0] if ids.size() >= 1 else -1)
	_atualizar_player_ui(2, ids[1] if ids.size() >= 2 else -1)

func _atualizar_player_ui(slot: int, peer_id: int):
	var nome_label   = p1_name   if slot == 1 else p2_name
	var ping_label   = p1_ping   if slot == 1 else p2_ping
	var status_label = p1_status if slot == 1 else p2_status

	if peer_id == -1:
		nome_label.text   = "Aguardando..."
		ping_label.text   = "-- ms"
		status_label.text = "Preparando"
		status_label.modulate = Color.ORANGE
		return

	var data = Network.players[peer_id]
	nome_label.text = data.get("name", "Jogador " + str(peer_id))
	ping_label.text = str(data.get("ping", 0)) + " ms"

	if data.get("ready", false):
		status_label.text = "Pronto ✅"
		status_label.modulate = Color.GREEN
	else:
		status_label.text = "Preparando"
		status_label.modulate = Color.ORANGE

func _on_player_connected(_id: int):
	_atualizar_todos()

func _on_player_disconnected(_id: int):
	_atualizar_todos()
	btn_comecar.disabled = true

func _on_ready_changed(_id: int):
	_atualizar_todos()

func _on_all_ready():
	if multiplayer.is_server():
		btn_comecar.disabled = false

func _on_button_pronto_pressed():
	eu_estou_pronto = not eu_estou_pronto
	Network.set_ready(eu_estou_pronto)

	var meu_slot = 1 if multiplayer.is_server() else 2
	var btn = p1_btn_pronto if meu_slot == 1 else p2_btn_pronto
	btn.text = "Cancelar" if eu_estou_pronto else "Pronto"

func _on_jogar_pressed():
	Network.start_game()
