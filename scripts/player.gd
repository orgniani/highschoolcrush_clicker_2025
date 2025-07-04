extends CharacterBody2D

@export var config: HumanConfig
@onready var animator: HumanAnimator = $HumanAnimator

@export var speed: float = 100

var last_follower: CharacterBody2D = self
var _can_move := true

func _ready():
	if GlobalGameState.player == null:
		GlobalGameState.player = self
	else:
		GlobalGameState.player.global_position = global_position
		queue_free()
	
	animator.apply_config(config)
	animator.play_animation("idle", false)

func _physics_process(delta: float) -> void:
	if not _can_move:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	var input_vector = Vector2.ZERO

	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1

	input_vector = input_vector.normalized() * speed
	velocity = input_vector
	move_and_slide()
	
	var is_moving = velocity.length() > 0

	var anim = "walk" if is_moving else "idle"
	animator.play_animation(anim, velocity.x, true)
	pass

func on_game_over():
	set_physics_process(false)
	var is_facing_left = animator.is_facing_left()
	animator.play_animation("idle", is_facing_left)
	
func on_allow_movement(allowed: bool):
	_can_move = allowed
	if not allowed:
		velocity = Vector2.ZERO
		animator.play_animation("idle", animator.is_facing_left(), true)
