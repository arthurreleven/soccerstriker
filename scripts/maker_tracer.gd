extends Node

var udp := PacketPeerUDP.new()
var marker_detected := false
var marker_pos := Vector2.ZERO
var marker_rotation := 0.0

func _ready() -> void:
	var err = udp.bind(5005)
	print("UDP bind resultado: ", err)

func _process(_delta: float) -> void:
	if udp.get_available_packet_count() > 0:
		print("Pacote recebido!")
		var raw  = udp.get_packet().get_string_from_utf8()
		var data = JSON.parse_string(raw)
		print("Dado: ", raw)

		if data == null:
			return

		marker_detected = data.get("detected", false)

		if marker_detected:
			marker_pos.x    = data.get("x", 0.0)
			marker_pos.y    = data.get("y", 0.0)
			marker_rotation = deg_to_rad(data.get("angle", 0.0))
