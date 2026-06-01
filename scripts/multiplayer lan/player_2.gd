extends CharacterBody2D

var speed = 160
var jump_force = -500
var gravity = 980
var can_kick = true
var is_kicking = false
var facing_dir = 1
var bloqueado = false

@onready var anim = $AnimatedSprite2D
@onready var kick_area = $KickArea
@onready var game_manager = get_node("/root/MainMultiplayer/GameManager")

func _ready():
	anim.animation_finished.connect(_on_animation_finished)

func _physics_process(delta):
	if not multiplayer.has_multiplayer_peer():
		return

	if multiplayer.is_server():
		if not is_on_floor():
			velocity.y += gravity * delta
		if bloqueado:
			velocity.x = 0
			move_and_slide()
		return

	if is_multiplayer_authority():
		var dir = Input.get_axis("Left2", "Right2")
		var jump = Input.is_action_just_pressed("Jump2")
		var kick = Input.is_action_just_pressed("Kick2") and can_kick and not is_kicking
		_enviar_input.rpc_id(1, dir, jump, kick)

		if dir != 0:
			facing_dir = dir
			anim.flip_h = dir < 0
		velocity.x = dir * speed
		if not is_on_floor():
			velocity.y += gravity * delta
		move_and_slide()

@rpc("any_peer", "unreliable")
func _enviar_input(dir: float, jump: bool, kick: bool):
	if not multiplayer.is_server():
		return
	if bloqueado:
		return
	_simular(get_physics_process_delta_time(), {"dir": dir, "jump": jump, "kick": kick})

func _simular(delta: float, input: Variant):
	var dir: float
	var jump: bool
	var kick: bool

	if input == null:
		dir = Input.get_axis("Left2", "Right2")
		jump = Input.is_action_just_pressed("Jump2")
		kick = Input.is_action_just_pressed("Kick2") and can_kick and not is_kicking
	else:
		dir = input["dir"]
		jump = input["jump"]
		kick = input["kick"]

	if dir != 0:
		facing_dir = dir
		anim.flip_h = dir < 0

	velocity.x = dir * speed

	if not is_on_floor():
		velocity.y += gravity * delta

	if jump and is_on_floor() and not is_kicking:
		velocity.y = jump_force
		game_manager.tocar_pulo()

	if kick:
		is_kicking = true
		can_kick = false
		anim.play("Kick")
		chutar_bola()
		game_manager.tocar_chute()
		get_tree().create_timer(0.5).timeout.connect(func(): is_kicking = false)
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

	var client_id = get_multiplayer_authority()
	_sync_estado.rpc_id(client_id, global_position, velocity, anim.animation, anim.flip_h)

@rpc("any_peer", "unreliable")
func _sync_estado(pos: Vector2, vel: Vector2, animation: String, flip: bool):
	if multiplayer.is_server():
		return
	global_position = pos
	velocity = vel
	anim.play(animation)
	anim.flip_h = flip

func mover_bola():
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
