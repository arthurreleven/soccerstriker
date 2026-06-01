extends Control

@onready var progress_bar = $ProgressBar
@onready var loading_label = $Label

var duration := 5.0
var elapsed := 0.0

var dots := 0
var dot_timer := 0.0

func _process(delta):
	$TextureRect2.scale = Vector2.ONE * (1.0 + sin(Time.get_ticks_msec() * 0.003) * 0.03)
	elapsed += delta

	var progress = (elapsed / duration) * 100
	progress_bar.value = clamp(progress, 0, 100)

	dot_timer += delta

	if dot_timer >= 0.4:
		dot_timer = 0

		dots += 1

		if dots > 3:
			dots = 0

		loading_label.text = "Loading" + ".".repeat(dots)

	if elapsed >= duration:

		get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
