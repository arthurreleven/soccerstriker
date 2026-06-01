extends CharacterBody2D

var speed = 160
var jump_force = -500
var gravity = 980
var can_kick = true
var is_kicking = false
var facing_dir = 1

@onready var anim = $AnimatedSprite2D
@onready var kick_area = $KickArea
@onready var game_manager = get_node("/root/MainMultiplayer/GameManager")

func _ready():
	anim.animation_finished.connect(_on_animation_finished)

func _physics_process(delta):
	if not multiplayer.has_multiplayer_peer():
		return
	if not is_multiplayer_authority():
		if not is_on_floor():
			velocity.y += gravity * delta
		move_and_slide()
		return


	var dir = Input.get_axis("Left", "Right")

	if dir != 0:
		facing_dir = dir
		anim.flip_h = dir < 0

	velocity.x = dir * speed

	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("Jump") and is_on_floor() and not is_kicking:
		velocity.y = jump_force
		game_manager.tocar_pulo()

	if Input.is_action_just_pressed("Kick") and not is_kicking:
		can_kick = false
		is_kicking = true
		anim.play("Kick")
		chutar_bola()
		game_manager.tocar_chute()
		get_tree().create_timer(0.3).timeout.connect(func(): can_kick = true)

	if is_kicking:
		if anim.animation != "Kick":
			anim.play("Kick")
	else:
		if not is_on_floor():
			anim.play("Jump")
		elif dir != 0:
			anim.play("Run")
		else:
			anim.play("Idle")

	move_and_slide()
	mover_bola()

func mover_bola():
	if not is_multiplayer_authority():
		return
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() is RigidBody2D:
			var ball = collision.get_collider()
			ball.apply_impulse(Vector2(velocity.x * 0.05, 0))

func chutar_bola():
	for body in kick_area.get_overlapping_bodies():
		if body is RigidBody2D:
			var direction = Vector2(facing_dir, -0.2).normalized()
			body.kick(direction)

func _on_animation_finished():
	if anim.animation == "Kick":
		is_kicking = false
