extends Node2D

class_name HumanAnimator

@export var parts: Array[HumanPartAnimator]

var _last_flip_left := false

func apply_config(config: HumanConfig):
	for part in parts:
		match part.animated_sprite.name:
			"body":
				part.animated_sprite.frames = config.body_sprite_frames
			"hair":
				part.animated_sprite.frames = config.hair_sprite_frames
			"hand":
				part.animated_sprite.frames = config.hand_sprite_frames

func play_animation(animation_name: String, direction_or_flip, remember_direction := false):
	var flip: bool

	if remember_direction:
		if abs(direction_or_flip) > 0.01:
			_last_flip_left = direction_or_flip < 0
		flip = _last_flip_left
	else:
		flip = direction_or_flip
		_last_flip_left = flip

	for part in parts:
		part.play(animation_name, flip)

func is_facing_left() -> bool:
	return _last_flip_left
