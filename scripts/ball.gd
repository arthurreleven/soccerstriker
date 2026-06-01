extends RigidBody2D

@export var force := 650.0
@export var max_speed := 1000.0
@export var upward_bias := -0.55
@export var spin_multiplier := 18.0

@onready var som_chute = get_node("/root/Main/GameManager/SomChute")

func _ready():
	linear_damp = 0.08
	angular_damp = 1.5
	mass = 0.8
	gravity_scale = 0.55
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.bounce = 0.78
	physics_material_override.friction = 0.25

func _physics_process(_delta):
	if freeze:
		return
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed
	angular_velocity = clamp(angular_velocity, -25.0, 25.0)

func kick(direction: Vector2, bonus_speed: float = 0.0):
	linear_velocity = Vector2(linear_velocity.x * 0.25, 0)
	var kick_dir = direction.normalized()
	kick_dir.y = min(kick_dir.y, upward_bias)
	kick_dir = kick_dir.normalized()
	var speed_bonus = clamp(abs(bonus_speed) / 160.0, 0.0, 0.2)
	var final_force = force * (1.0 + speed_bonus)
	apply_impulse(kick_dir * final_force)
	angular_velocity += kick_dir.x * spin_multiplier
	som_chute.play()

func kick_header(direction: Vector2, contact_offset: float = 0.0):
	linear_velocity *= 0.25

	var kick_dir = direction.normalized()

	var offset_normalized = clamp(contact_offset / 24.0, -1.0, 1.0)
	kick_dir.x = lerp(kick_dir.x, offset_normalized, 0.45)

	kick_dir.y = clamp(kick_dir.y, -0.95, -0.55)
	kick_dir = kick_dir.normalized()

	apply_impulse(kick_dir * force * 1.2)
	angular_velocity += offset_normalized * spin_multiplier * 1.2
	som_chute.play()

func kick_aerial(direction: Vector2, bonus_speed: float = 0.0):
	linear_velocity = Vector2(linear_velocity.x * 0.1, linear_velocity.y * 0.1)
	var kick_dir = direction.normalized()
	kick_dir.y = min(kick_dir.y, upward_bias + 0.15)
	kick_dir = kick_dir.normalized()
	var speed_bonus = clamp(abs(bonus_speed) / 160.0, 0.0, 0.25)
	var final_force = force * 1.2 * (1.0 + speed_bonus)
	apply_impulse(kick_dir * final_force)
	angular_velocity += kick_dir.x * spin_multiplier * 1.2
	som_chute.play()

func resetar(pos: Vector2) -> void:
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

	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	freeze = false
