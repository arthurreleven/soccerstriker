extends Control

@onready var btn_comecar = $Jogar
@onready var btn_cancelar = $Cancelar

@onready var p1_name   = $Player1/Name
@onready var p1_estado = $Player1/Estado
@onready var p1_status = $Player1/On
@onready var p1_luz = $Player1/Luz

@onready var p2_name   = $Player2/Name
@onready var p2_estado = $Player2/Estado
@onready var p2_status = $Player2/On
@onready var p2_luz = $Player2/Luz

@onready var ip_label = $IPLabel

@onready var qr_code = $QRCode

func _ready():
	Server.iniciar()
	btn_comecar.disabled = true
	_set_slot_offline(1)
	_set_slot_offline(2)
	Server.player_connected.connect(_on_player_connected)
	_mostrar_ip()
	
func _arredondar_luz(luz: Panel, cor: Color):
	var style = StyleBoxFlat.new()
	style.bg_color = cor
	style.corner_radius_top_left = 50
	style.corner_radius_top_right = 50
	style.corner_radius_bottom_left = 50
	style.corner_radius_bottom_right = 50
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = cor.darkened(0.4)
	luz.add_theme_stylebox_override("panel", style)

func _mostrar_ip():
	var ip = ""
	for addr in IP.get_local_addresses():
		if addr.begins_with("192.") or addr.begins_with("10."):
			ip = addr
			break
	if ip == "":
		ip_label.text = "IP não encontrado"
	else:
		var link = "https://arthurreleven.github.io/controle/?ip=" + ip
		ip_label.text = link
		_gerar_qrcode(link)
		
func _gerar_qrcode(link: String):
	var url = "https://api.qrserver.com/v1/create-qr-code/?size=120x120&data=" + link.uri_encode()
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_qrcode_recebido.bind(http))
	http.request(url)
	
func _on_qrcode_recebido(result, response_code, headers, body, http):
	if response_code == 200:
		var image = Image.new()
		image.load_png_from_buffer(body)
		var texture = ImageTexture.create_from_image(image)
		qr_code.texture = texture
	http.queue_free()

func _set_slot_offline(slot: int):
	if slot == 1:
		p1_name.text   = "Player 1"
		p1_estado.text = "Aguardando..."
		p1_status.text = "Offline"
		p1_status.modulate = Color.ORANGE
		_arredondar_luz(p1_luz, Color.RED)
	else:
		p2_name.text   = "Player 2"
		p2_estado.text = "Aguardando..."
		p2_status.text = "Offline"
		p2_status.modulate = Color.ORANGE
		_arredondar_luz(p2_luz, Color.RED)

func _on_player_connected(slot: int):
	if slot == 1:
		p1_estado.text = "Online"
		p1_status.text = "Host"
		p1_status.modulate = Color.GREEN
		_arredondar_luz(p1_luz, Color.GREEN)
	elif slot == 2:
		p2_estado.text = "Online"
		p2_status.text = "Conectado"
		p2_status.modulate = Color.GREEN
		_arredondar_luz(p2_luz, Color.GREEN)
		btn_comecar.disabled = false

func _on_jogar_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_cancelar_pressed():
	Server.peer = WebSocketMultiplayerPeer.new()
	Server.players.clear()
	Server.player_order.clear()
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
