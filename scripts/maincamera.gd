extends Node

@onready var tracker = $"../MakerTracker"
@onready var field = $"../Field"
@onready var ball = $"../Field/Ball"
@onready var player1 = $"../Field/Player1"
@onready var player2 = $"../Field/Player2"
@onready var status_label = $"../HUD/StatusLabel"

var cam_w: float = 640.0
var cam_h: float = 480.0

func _ready() -> void:
	field.visible = false
	status_label.text = "Aponte para o marcador"

	ball.freeze = true
	
func _process(_delta: float) -> void:
	if tracker.marker_detected:
		_on_marker_found()
	else:
		_on_marker_lost()
		
		
func _on_marker_found() -> void:
	if not field.visible:
		field.visible = true
		ball.freeze    = false

	var screen = get_viewport().get_visible_rect().size
	var target = Vector2(
		tracker.marker_pos.x / cam_w * screen.x,
		tracker.marker_pos.y / cam_h * screen.y
	)

	field.position = field.position.lerp(target, 0.15)
	field.rotation  = tracker.marker_rotation

	status_label.text = "Marcador detectado"
	

func _on_marker_lost() -> void:
	field.visible = false
	ball.freeze    = true
	status_label.text = "Aponte para o marcador"
