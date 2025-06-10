extends Node

class_name LoverPatrol

@export var patrol_range_min: float = 10.0
@export var patrol_range_max: float = 30.0
@export var patrol_speed_min: float = 10.0
@export var patrol_speed_max: float = 20.0
@export var wait_time: float = 1.0

var _lover: CharacterBody2D
var _animator: HumanAnimator

var _left_limit: Vector2
var _right_limit: Vector2

var _patrol_range: float
var _patrol_speed: float

var _direction: int = 1
var _waiting: bool = false
var _wait_timer: float = 0.0
var _active: bool = false

func setup(animator: HumanAnimator, lover: CharacterBody2D):
	_lover = lover
	_animator = animator

	_patrol_range = randf_range(patrol_range_min, patrol_range_max)
	_patrol_speed = randf_range(patrol_speed_min, patrol_speed_max)

	var start_x = _lover.global_position.x
	var y = _lover.global_position.y
	_left_limit = Vector2(start_x - _patrol_range, y)
	_right_limit = Vector2(start_x + _patrol_range, y)

	_active = true
	set_physics_process(true)

func stop():
	_active = false

func start():
	_active = true

func _physics_process(delta: float) -> void:
	if not _active or _lover == null:
		return

	if _waiting:
		_wait_timer -= delta
		if _wait_timer <= 0.0:
			_waiting = false
			_direction *= -1
		else:
			return

	var move_dir = Vector2(_direction, 0)
	var next_pos = _lover.global_position + move_dir * _patrol_speed * delta

	if _direction == 1 and next_pos.x >= _right_limit.x:
		_wait()
		return
	elif _direction == -1 and next_pos.x <= _left_limit.x:
		_wait()
		return

	_lover.global_position = next_pos
	_animator.play_animation("walk", _direction < 0)

func _wait():
	_waiting = true
	_wait_timer = wait_time
	_animator.play_animation("idle", _direction < 0)
