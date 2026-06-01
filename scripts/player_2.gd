extends CharacterBody2D

var speed = 160
var jump_force = -500
var gravity = 980

var is_kicking = false
var facing_dir = 1

var last_kick_time = 0.0
var double_click_time = 0.25

@onready var anim = $AnimatedSprite2D
@onready var kick_area = $KickArea
@onready var game_manager = $"../GameManager"


func _ready():
	anim.animation_finished.connect(_on_animation_finished)


func _physics_process(delta):
	var dir = 0
	var input_jump = false
	var input_kick = false

	if GameState.multiplayer_mode:
		var input = Server.get_input(1)
		if input["left"]: dir -= 1
		if input["right"]: dir += 1
		input_jump = input["jump"]
		input_kick = input["kick"]
	else:
		dir = Input.get_axis("Left2", "Right2")
		input_jump = Input.is_action_just_pressed("Jump2")
		input_kick = Input.is_action_just_pressed("Kick2")

	if dir != 0:
		facing_dir = dir
		anim.flip_h = dir < 0
	velocity.x = dir * speed
	if not is_on_floor():
		velocity.y += gravity * delta
	if input_jump and is_on_floor() and not is_kicking:
		velocity.y = jump_force
		game_manager.tocar_pulo()
	if input_kick and not is_kicking:
		is_kicking = true
		anim.play("Kick")
		chutar_bola()
		game_manager.tocar_chute()
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
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() is RigidBody2D:
			var ball = collision.get_collider()

			var force = Vector2(velocity.x * 0.05, 0)

			ball.apply_impulse(force)


func chutar_bola():
	for body in kick_area.get_overlapping_bodies():
		if body is RigidBody2D:
			var direction = Vector2(facing_dir, -0.2).normalized()
			body.kick(direction)


func _on_animation_finished():
	if anim.animation == "Kick":
		is_kicking = false
