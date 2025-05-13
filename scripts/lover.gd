extends Area2D

@export var config: HumanConfig
@onready var animator: HumanAnimator = $HumanAnimator

func _ready():
	animator.apply_config(config)
	animator.play_animation("idle", false)
