extends Control

var modo_selecionado = ""
var mapa_selecionado = ""

var estilo_normal: StyleBoxFlat
var estilo_selecionado: StyleBoxFlat

func _ready():
	estilo_normal = StyleBoxFlat.new()
	estilo_normal.bg_color = Color(0.15, 0.15, 0.15)
	estilo_normal.border_width_left = 1
	estilo_normal.border_width_right = 1
	estilo_normal.border_width_top = 1
	estilo_normal.border_width_bottom = 1
	estilo_normal.border_color = Color(0.4, 0.4, 0.4)
	estilo_normal.corner_radius_top_left = 8
	estilo_normal.corner_radius_top_right = 8
	estilo_normal.corner_radius_bottom_left = 8
	estilo_normal.corner_radius_bottom_right = 8

	estilo_selecionado = StyleBoxFlat.new()
	estilo_selecionado.bg_color = Color(0.2, 0.5, 1.0, 0.3)
	estilo_selecionado.border_width_left = 2
	estilo_selecionado.border_width_right = 2
	estilo_selecionado.border_width_top = 2
	estilo_selecionado.border_width_bottom = 2
	estilo_selecionado.border_color = Color(0.2, 0.5, 1.0)
	estilo_selecionado.corner_radius_top_left = 8
	estilo_selecionado.corner_radius_top_right = 8
	estilo_selecionado.corner_radius_bottom_left = 8
	estilo_selecionado.corner_radius_bottom_right = 8
	
func _on_card_mapa_1_pressed():
	if modo_selecionado == "":
		return
	mapa_selecionado = "mapa_1"
	_atualizar_estilo_mapas($CardMapa1)
	_atualizar_botao_jogar()

func _on_card_mapa_2_pressed():
	if modo_selecionado == "":
		return
	mapa_selecionado = "mapa_2"
	_atualizar_estilo_mapas($CardMapa2)
	_atualizar_botao_jogar()

func _on_card_mapa_3_pressed():
	if modo_selecionado == "":
		return
	mapa_selecionado = "mapa_3"
	_atualizar_estilo_mapas($CardMapa3)
	_atualizar_botao_jogar()

func _atualizar_estilo_mapas(selecionado):
	var mapas = [$CardMapa1, $CardMapa2, $CardMapa3]
	for card in mapas:
		if card == selecionado:
			card.add_theme_stylebox_override("normal", estilo_selecionado)
		else:
			card.add_theme_stylebox_override("normal", estilo_normal)

func _on_local_pressed():
	modo_selecionado = "local"

	$Local.add_theme_stylebox_override("normal", estilo_selecionado)

	$Multiplayer.add_theme_stylebox_override("normal", estilo_normal)
	$LAN.add_theme_stylebox_override("normal", estilo_normal)

	_atualizar_botao_jogar()


func _on_multiplayer_pressed():
	modo_selecionado = "multiplayer"

	$Multiplayer.add_theme_stylebox_override("normal", estilo_selecionado)

	$Local.add_theme_stylebox_override("normal", estilo_normal)
	$LAN.add_theme_stylebox_override("normal", estilo_normal)

	_atualizar_botao_jogar()


func _on_lan_pressed():
	modo_selecionado = "lan"

	$LAN.add_theme_stylebox_override("normal", estilo_selecionado)

	$Local.add_theme_stylebox_override("normal", estilo_normal)
	$Multiplayer.add_theme_stylebox_override("normal", estilo_normal)

	_atualizar_botao_jogar()

func _atualizar_botao_jogar():
	$Jogar.disabled = (modo_selecionado == "" or mapa_selecionado == "")

func _on_jogar_pressed():

	GameState.multiplayer_mode = (modo_selecionado == "multiplayer")
	GameState.lan_mode = (modo_selecionado == "lan")

	if modo_selecionado == "lan":
		get_tree().change_scene_to_file("res://scenes/multiplayer lan/MenuMultiplayer.tscn")
	elif modo_selecionado == "multiplayer":
		get_tree().change_scene_to_file("res://scenes/lobbymul.tscn")
	else:
		match mapa_selecionado:
			"mapa_1":
				get_tree().change_scene_to_file("res://scenes/main.tscn")
			"mapa_2":
				get_tree().change_scene_to_file("res://scenes/main2.tscn")
			"mapa_3":
				get_tree().change_scene_to_file("res://scenes/main3.tscn")
