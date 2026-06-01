extends CanvasLayer

@onready var label_tempo = $Control/LabelTempo
@onready var label_p1 = $Control/LabelP1
@onready var label_p2 = $Control/LabelP2
@onready var painel_fim = $Control/PainelFim
@onready var label_vencedor = $Control/LabelVencedor
@onready var botao_reiniciar = $Control/PainelFim/BotaoReiniciar
@onready var botao_quit = $Control/PainelFim/BotaoQuit

var _fim_montado := false

func _ready():
	label_tempo.text = "01:30"
	label_p1.text = "0"
	label_p2.text = "0"
	painel_fim.visible = false
	botao_reiniciar.pressed.connect(_on_reiniciar)
	botao_quit.pressed.connect(_on_quit)

func atualizar_tempo(segundos: float):
	var mn = int(segundos) / 60
	var sc = int(segundos) % 60
	label_tempo.text = "%02d:%02d" % [mn, sc]

func atualizar_placar(p1: int, p2: int):
	label_p1.text = str(p1)
	label_p2.text = str(p2)

func mostrar_fim(p1: int, p2: int):
	label_tempo.visible = false
	label_p1.visible    = false
	label_p2.visible    = false
	label_vencedor.visible = false

	painel_fim.set_anchors_preset(Control.PRESET_FULL_RECT)
	painel_fim.offset_left   = 0
	painel_fim.offset_top    = 0
	painel_fim.offset_right  = 0
	painel_fim.offset_bottom = 0
	painel_fim.visible = true

	if not _fim_montado:
		_montar_tela_fim()
		_fim_montado = true

	var lv  : Label  = painel_fim.get_node("LV")
	var lp1 : Label  = painel_fim.get_node("LP1")
	var lp2 : Label  = painel_fim.get_node("LP2")

	lp1.add_theme_color_override("font_color", Color.WHITE)
	lp2.add_theme_color_override("font_color", Color.WHITE)
	lp1.add_theme_font_size_override("font_size", 64)
	lp2.add_theme_font_size_override("font_size", 64)

	if p1 > p2:
		lv.text  = "🏆  Player 1 Venceu!"
		lp1.add_theme_color_override("font_color", Color("#FFD700"))
		lp1.add_theme_font_size_override("font_size", 72)
	elif p2 > p1:
		lv.text  = "🏆  Player 2 Venceu!"
		lp2.add_theme_color_override("font_color", Color("#FFD700"))
		lp2.add_theme_font_size_override("font_size", 72)
	else:
		lv.text = "🤝  Empate!"

	lp1.text = str(p1)
	lp2.text = str(p2)

	painel_fim.modulate.a = 0.0
	var tw = create_tween()
	tw.tween_property(painel_fim, "modulate:a", 1.0, 0.45)

func _montar_tela_fim():
	var tela = get_viewport().get_visible_rect().size

	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.78)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	painel_fim.add_child(bg)

	var cw = 420.0
	var ch = 310.0
	var cx = (tela.x - cw) / 2.0
	var cy = (tela.y - ch) / 2.0

	var card = ColorRect.new()
	card.position = Vector2(cx, cy)
	card.size     = Vector2(cw, ch)
	card.color    = Color("#0d0d1f")
	painel_fim.add_child(card)

	var borda = Panel.new()
	borda.position = Vector2(cx, cy)
	borda.size     = Vector2(cw, ch)
	var sb = StyleBoxFlat.new()
	sb.bg_color    = Color(0, 0, 0, 0)
	sb.border_color = Color("#FFD700")
	for side in [0,1,2,3]: sb.set("border_width_" + ["left","top","right","bottom"][side], 2)
	sb.corner_radius_top_left     = 14
	sb.corner_radius_top_right    = 14
	sb.corner_radius_bottom_left  = 14
	sb.corner_radius_bottom_right = 14
	borda.add_theme_stylebox_override("panel", sb)
	painel_fim.add_child(borda)

	var lv = Label.new()
	lv.name = "LV"
	lv.position = Vector2(cx, cy + 22)
	lv.size     = Vector2(cw, 52)
	lv.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lv.add_theme_font_size_override("font_size", 28)
	lv.add_theme_color_override("font_color", Color("#FFD700"))
	painel_fim.add_child(lv)

	var lp1 = Label.new()
	lp1.name = "LP1"
	lp1.position = Vector2(cx + 50, cy + 90)
	lp1.size     = Vector2(120, 90)
	lp1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lp1.add_theme_font_size_override("font_size", 64)
	lp1.add_theme_color_override("font_color", Color.WHITE)
	painel_fim.add_child(lp1)

	var sep = Label.new()
	sep.text = "×"
	sep.position = Vector2(cx + cw/2 - 18, cy + 102)
	sep.size     = Vector2(36, 60)
	sep.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sep.add_theme_font_size_override("font_size", 36)
	sep.add_theme_color_override("font_color", Color("#444455"))
	painel_fim.add_child(sep)

	var lp2 = Label.new()
	lp2.name = "LP2"
	lp2.position = Vector2(cx + cw - 170, cy + 90)
	lp2.size     = Vector2(120, 90)
	lp2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lp2.add_theme_font_size_override("font_size", 64)
	lp2.add_theme_color_override("font_color", Color.WHITE)
	painel_fim.add_child(lp2)

	botao_reiniciar.position = Vector2(cx + (cw - 300)/2, cy + 210)
	botao_reiniciar.size     = Vector2(300, 44)
	botao_reiniciar.text     = "Jogar Novamente"
	_estilo_botao(botao_reiniciar, Color("#1a6fff"), Color.WHITE)

	botao_quit.position = Vector2(cx + (cw - 300)/2, cy + 260)
	botao_quit.size     = Vector2(300, 44)
	botao_quit.text     = "Sair"
	_estilo_botao(botao_quit, Color("#1a1a2e"), Color("#888888"))

	painel_fim.move_child(botao_reiniciar, painel_fim.get_child_count() - 1)
	painel_fim.move_child(botao_quit,      painel_fim.get_child_count() - 1)

func _estilo_botao(btn: Button, cor_bg: Color, cor_txt: Color):
	var sb = StyleBoxFlat.new()
	sb.bg_color = cor_bg
	sb.corner_radius_top_left     = 8
	sb.corner_radius_top_right    = 8
	sb.corner_radius_bottom_left  = 8
	sb.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("normal",  sb)
	btn.add_theme_stylebox_override("hover",   sb)
	btn.add_theme_stylebox_override("pressed", sb)
	btn.add_theme_color_override("font_color", cor_txt)
	btn.add_theme_font_size_override("font_size", 15)

func _on_reiniciar():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit():
	get_tree().quit()
