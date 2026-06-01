extends CharacterBody2D

@export var speed       : float = 200.0
@export var joystick_id : int   = 0

var _touch_id    : int     = -1
var _joy_origin  : Vector2 = Vector2.ZERO
var _joy_current : Vector2 = Vector2.ZERO
var _direction   : Vector2 = Vector2.ZERO

const JOY_RADIUS : float = 60.0

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _touch_id == -1:
			if _is_my_side(event.position):
				_touch_id   = event.index
				_joy_origin  = event.position
				_joy_current = event.position
		elif not event.pressed and event.index == _touch_id:
			_touch_id   = -1
			_direction  = Vector2.ZERO
			_joy_origin  = Vector2.ZERO
			_joy_current = Vector2.ZERO

	elif event is InputEventScreenDrag:
		if event.index == _touch_id:
			_joy_current = event.position
			var diff     = _joy_current - _joy_origin
			if diff.length() > JOY_RADIUS:
				diff = diff.normalized() * JOY_RADIUS
			_direction = diff / JOY_RADIUS

func _physics_process(_delta: float) -> void:
	velocity = _direction * speed
	move_and_slide()

func _is_my_side(pos: Vector2) -> bool:
	var mid = get_viewport().get_visible_rect().size.x / 2.0
	if joystick_id == 0:
		return pos.x < mid
	else:
		return pos.x >= mid
