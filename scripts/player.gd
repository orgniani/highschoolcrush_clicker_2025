extends CharacterBody2D

@export var config: HumanConfig
@onready var animator: HumanAnimator = $HumanAnimator

@export var speed: float = 100
var _last_flip_left: bool = false

func _ready():
	animator.apply_config(config)
	animator.play_animation("idle", false)

func _physics_process(delta: float) -> void:
	var input_vector = Vector2.ZERO

	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1

	input_vector = input_vector.normalized() * speed
	velocity = input_vector
	move_and_slide()
	
	var is_moving = velocity.length() > 0

	if is_moving:
		_last_flip_left = velocity.x < 0

	var anim = "walk" if is_moving else "idle"
	animator.play_animation(anim, _last_flip_left)
pass
