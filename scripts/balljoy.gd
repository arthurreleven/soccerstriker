extends RigidBody2D

@export var kick_force    : float = 800.0
@export var max_speed     : float = 600.0
@export var friction      : float = 0.92

func _physics_process(_delta: float) -> void:
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed
	
	linear_velocity *= friction

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D:
		var dir      = (global_position - body.global_position).normalized()
		var strength = body.velocity.length()
		apply_central_impulse(dir * strength * kick_force / max_speed)
