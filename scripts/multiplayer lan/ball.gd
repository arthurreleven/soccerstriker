extends RigidBody2D

@export var force := 900.0
@export var max_speed := 1200.0
@export var upward_bias := -0.65
@export var spin_multiplier := 18.0

var _target_pos := Vector2.ZERO

@onready var chao_y = 276.0
@onready var som_chute = get_node("/root/MainMultiplayer/GameManager/SomChute")

func _ready():
	linear_damp = 0.08
	angular_damp = 1.5
	mass = 0.8
	gravity_scale = 0.55
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.bounce = 0.78
	physics_material_override.friction = 0.25

	if not multiplayer.has_multiplayer_peer():
		return

	if not multiplayer.is_server():
		freeze = true
		freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
		gravity_scale = 0.0
		for child in get_children():
			if child is CollisionShape2D or child is CollisionPolygon2D:
				child.set_deferred("disabled", true)

func _physics_process(_delta):
	if not multiplayer.is_server():
		return
	if freeze:
		return
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed
	angular_velocity = clamp(angular_velocity, -25.0, 25.0)
	_sync_posicao.rpc(global_position)

@rpc("authority", "unreliable")
func _sync_posicao(pos: Vector2):
	if multiplayer.is_server():
		return
	_target_pos = Vector2(pos.x, min(pos.y, chao_y))
	global_position = _target_pos

func _process(delta):
	pass
	
func kick(direction: Vector2, bonus_speed: float = 0.0):
	if multiplayer.is_server():
		_aplicar_kick(direction, bonus_speed)
	else:
		_pedir_kick.rpc_id(1, direction, bonus_speed)

@rpc("any_peer", "reliable")
func _pedir_kick(direction: Vector2, bonus_speed: float):
	if multiplayer.is_server():
		_aplicar_kick(direction, bonus_speed)

func _aplicar_kick(direction: Vector2, bonus_speed: float = 0.0):
	linear_velocity = Vector2(linear_velocity.x * 0.25, 0)
	var kick_dir = direction.normalized()
	kick_dir.y = min(kick_dir.y, upward_bias)
	kick_dir = kick_dir.normalized()
	var speed_bonus = clamp(abs(bonus_speed) / 160.0, 0.0, 0.2)
	apply_impulse(kick_dir * force * (1.0 + speed_bonus))
	angular_velocity += kick_dir.x * spin_multiplier
	_tocar_som_chute.rpc()

@rpc("authority", "call_local", "unreliable")
func _tocar_som_chute():
	som_chute.play()

func kick_header(direction: Vector2, contact_offset: float = 0.0):
	if multiplayer.is_server():
		_aplicar_header(direction, contact_offset)
	else:
		_pedir_header.rpc_id(1, direction, contact_offset)

@rpc("any_peer", "reliable")
func _pedir_header(direction: Vector2, contact_offset: float):
	if multiplayer.is_server():
		_aplicar_header(direction, contact_offset)

func _aplicar_header(direction: Vector2, contact_offset: float = 0.0):
	linear_velocity *= 0.25
	var kick_dir = direction.normalized()
	var offset_normalized = clamp(contact_offset / 24.0, -1.0, 1.0)
	kick_dir.x = lerp(kick_dir.x, offset_normalized, 0.45)
	kick_dir.y = clamp(kick_dir.y, -0.95, -0.55)
	kick_dir = kick_dir.normalized()
	apply_impulse(kick_dir * force * 1.2)
	angular_velocity += offset_normalized * spin_multiplier * 1.2
	_tocar_som_chute.rpc()

func resetar(pos: Vector2) -> void:
	if not multiplayer.is_server():
		return
	freeze = true
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	await get_tree().physics_frame
	PhysicsServer2D.body_set_state(
		get_rid(),
		PhysicsServer2D.BODY_STATE_TRANSFORM,
		Transform2D(0, pos)
	)
	await get_tree().physics_frame
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	freeze = false
