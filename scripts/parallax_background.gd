extends Node2D

@export var speed = 150.0
@onready var sprites = [$BG1, $BG2]
var bg_width: float
var overlap = 1.0

func _ready():
	bg_width = sprites[0].texture.get_width() * sprites[0].scale.x
	sprites[0].position.x = bg_width / 2
	sprites[1].position.x = bg_width + bg_width / 2
	
func _process(delta):
	for sprite in sprites:
		sprite.position.x -= speed * delta
		if sprite.position.x < -(bg_width / 2):
			sprite.position.x += (bg_width * 2) - overlap
