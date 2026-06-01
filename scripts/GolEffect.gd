extends Control

@onready var label: Label = $Label

func _ready():
	label.visible = false
	_configurar_label()

func _configurar_label():
	label.text = "GOOOL!"
	label.add_theme_font_size_override("font_size", 80)
	label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	label.add_theme_constant_override("outline_size", 8)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_CENTER)
	label.pivot_offset = label.size / 2.0

func mostrar_gol():
	label.visible = true
	label.modulate.a = 1.0
	label.scale = Vector2(0.05, 0.05)

	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)

	tween.tween_property(label, "scale", Vector2(1.4, 1.4), 0.55)

	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(label, "scale", Vector2(1.55, 1.55), 0.12)
	tween.tween_property(label, "scale", Vector2(1.4,  1.4 ), 0.12)
	tween.tween_property(label, "scale", Vector2(1.5,  1.5 ), 0.10)
	tween.tween_property(label, "scale", Vector2(1.4,  1.4 ), 0.10)

	tween.tween_interval(0.6)

	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUAD)
	var saida = tween.parallel()
	saida.tween_property(label, "scale", Vector2(2.2, 2.2), 0.45)
	saida.tween_property(label, "modulate:a", 0.0, 0.45)

	tween.tween_callback(func(): label.visible = false)
	return tween

func _spawn_particulas():
	var cores = [
		Color(1.0, 0.85, 0.0),
		Color(1.0, 1.0, 1.0),
		Color(0.0, 0.9, 1.0),
		Color(1.0, 0.42, 0.21),
	]
	for i in range(30):
		var quad = ColorRect.new()
		add_child(quad)
		var tam = randf_range(6, 14)
		quad.size = Vector2(tam, tam)
		quad.color = cores[randi() % cores.size()]
		quad.position = get_viewport_rect().size / 2.0

		var angle = randf() * TAU
		var speed = randf_range(80, 320)
		var vel   = Vector2(cos(angle), sin(angle)) * speed

		var tw = create_tween()
		tw.set_parallel(true)
		tw.tween_property(quad, "position", quad.position + vel * 1.8, 1.2)
		tw.tween_property(quad, "modulate:a", 0.0, 1.0)
		tw.tween_property(quad, "rotation", randf_range(-TAU, TAU), 1.2)
		tw.chain().tween_callback(quad.queue_free)
