extends Area2D

@export var config: HumanConfig
@export var flip : bool
@onready var animator: HumanAnimator = $HumanAnimator

func _ready():
	animator.apply_config(config)
	animator.play_animation("idle", flip)
