extends Node

class_name LoverFollower

@export var follow_offset: Vector2 = Vector2(-20, 0)
@export var follow_speed: float = 100.0

var _follow_target: CharacterBody2D
var _lover: CharacterBody2D
var _animator: HumanAnimator
var _last_flip_left := false
var _cached_offset := Vector2.ZERO

func enable_follow(follow_target: CharacterBody2D, animator: HumanAnimator):
	_follow_target = follow_target
	_animator = animator
	_lover = get_parent()

	var desired_pos = _follow_target.global_position + follow_offset
	var direction = desired_pos - _lover.global_position

	if abs(direction.x) > 1.0:
		_last_flip_left = direction.x < 0

	_cached_offset = Vector2(
		abs(follow_offset.x) * (1 if _last_flip_left else -1),
		follow_offset.y
	)

	set_physics_process(true)

func disable_follow():
	_follow_target = null
	set_physics_process(false)

func _physics_process(delta):
	if not _follow_target:
		return

	var target_velocity = _follow_target.velocity
	var is_player_moving = target_velocity.length() > 0.1

	if is_player_moving:
		var flip_left = target_velocity.x < 0
		if flip_left != _last_flip_left:
			_last_flip_left = flip_left
			_cached_offset.x = abs(follow_offset.x) * (1 if _last_flip_left else -1)

	var target_pos = _follow_target.global_position + _cached_offset
	var move_dir = target_pos - _lover.global_position
	var distance = move_dir.length()
	var is_moving = distance > 1.0

	if is_moving:
		_lover.velocity = move_dir.normalized() * follow_speed
		_animator.play_animation("walk", _last_flip_left)
	else:
		_lover.velocity = Vector2.ZERO
		_animator.play_animation("idle", _last_flip_left)

	_lover.move_and_slide()
