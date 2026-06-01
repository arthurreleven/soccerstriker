extends Control

@onready var ip_input    = $VBoxContainer/IPInput
@onready var error_label = $VBoxContainer/ErrorLabel
@onready var ip_label    = $IPLabel

func _ready():
	var ip = IP.get_local_addresses()
	var ip_encontrado = ""
	
	for addr in ip:
		if ":" in addr:
			continue
		if addr.begins_with("192.168."):
			ip_encontrado = addr
			break
		elif addr.begins_with("10."):
			ip_encontrado = addr
	
	if ip_encontrado == "":
		ip_label.text = "IP não encontrado"
	else:
		ip_label.text = "Seu IP: " + ip_encontrado

func _on_host_pressed():
	Network.create_server()
	get_tree().change_scene_to_file("res://scenes/multiplayer lan/lobby.tscn")

func _on_join_pressed():
	var ip = ip_input.text.strip_edges()
	if ip == "":
		ip = "127.0.0.1"
	error_label.text = "Conectando..."
	Network.join_server(ip)
	multiplayer.connected_to_server.connect(func():
		get_tree().change_scene_to_file("res://scenes/multiplayer lan/lobby.tscn")
	, CONNECT_ONE_SHOT)
	multiplayer.connection_failed.connect(func():
		error_label.text = "Falha na conexão! Verifique o IP."
	, CONNECT_ONE_SHOT)

func _on_voltar_pressed():
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
