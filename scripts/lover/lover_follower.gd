extends Node

class_name LoverFollower

@export var follow_offset: Vector2 = Vector2(-20, 0)
@export var follow_speed: float = 100.0

var _follow_target: CharacterBody2D
var _lover: CharacterBody2D
var _animator: HumanAnimator
var _follow_target_animator: HumanAnimator
var _last_flip_left := false
var _cached_offset := Vector2.ZERO

func enable_follow(follow_target: CharacterBody2D, lover: CharacterBody2D):
	_follow_target = follow_target
	_lover = lover
	_animator = _lover.get_node("HumanAnimator")
	_follow_target_animator = _follow_target.get_node("HumanAnimator")

	_lover = lover

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

	var target_facing_left = _get_target_facing_left()
	var offset_distance = (_follow_target.global_position + _cached_offset - _lover.global_position).length()

	if _follow_target.velocity.length() > 1.0 or offset_distance > 5.0:
		_update_offset_based_on_facing(target_facing_left)

	var target_pos = _follow_target.global_position + _cached_offset
	var move_dir = target_pos - _lover.global_position
	var distance = move_dir.length()
	var is_moving = distance > 1.0

	if is_moving:
		var moving_left = move_dir.x < 0
		_lover.velocity = move_dir.normalized() * follow_speed
		_animator.play_animation("walk", moving_left)
	else:
		_lover.velocity = Vector2.ZERO
		_animator.play_animation("idle", target_facing_left)

	_lover.move_and_slide()

func _update_offset_based_on_facing(is_facing_left: bool):
	if is_facing_left != _last_flip_left:
		_last_flip_left = is_facing_left
		_cached_offset.x = abs(follow_offset.x) * (1 if is_facing_left else -1)

func _get_target_facing_left() -> bool:
	return _follow_target_animator.is_facing_left()
