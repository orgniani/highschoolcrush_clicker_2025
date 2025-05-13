extends Node2D

class_name HumanAnimator

@export var parts: Array[HumanPartAnimator]

func apply_config(config: HumanConfig):
	for part in parts:
		match part.animated_sprite.name:
			"body":
				part.animated_sprite.frames = config.body_sprite_frames
			"hair":
				part.animated_sprite.frames = config.hair_sprite_frames
			"hand":
				part.animated_sprite.frames = config.hand_sprite_frames

func play_animation(animation_name: String, flip: bool):
	for part in parts:
		part.play(animation_name, flip)
