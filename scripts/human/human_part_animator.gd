extends Node2D

class_name HumanPartAnimator

@export var animated_sprite: AnimatedSprite2D

func play(animation_name: String, flip: bool):
	
	if animated_sprite == null:
		push_error("[HumanPartAnimator] animated_sprite is NULL!")
		return

	animated_sprite.flip_h = flip
	animated_sprite.play(animation_name)
