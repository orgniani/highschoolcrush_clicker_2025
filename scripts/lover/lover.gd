extends CharacterBody2D

#References
@export var player : CharacterBody2D
@export var config: HumanConfig

@export var click_sound : AudioStream

#Parameters
@export var required_clicks: int = 10
@export var fill_time: float = 3.0

@onready var state_machine: LoverStateMachine = $"LoverStateMachine"
@onready var follower: LoverFollower = $"LoverFollower"
@onready var patrol: LoverPatrol = $"LoverPatrol"

@onready var animator: HumanAnimator = $"HumanAnimator"
@onready var heart_bar: TextureProgressBar = $"HeartBar"

func _ready():
	animator.apply_config(config)
	animator.play_animation("idle", false)
	
	heart_bar.max_value = required_clicks
	
	patrol.setup(animator)
	
	set_process(true)
	state_machine.setup(required_clicks, fill_time)
	state_machine.romance_success.connect(_on_romance_success)
	state_machine.romance_failed.connect(_on_romance_failed)
	state_machine.romance_started.connect(_on_romance_start)

func _process(delta):
	if Input.is_action_just_pressed("click"):
		var mouse_pos = get_global_mouse_position()
		var space_state = get_world_2d().direct_space_state

		var query := PhysicsPointQueryParameters2D.new()
		query.position = mouse_pos
		query.collide_with_areas = true
		query.exclude = []

		var results = space_state.intersect_point(query, 1)
		if results.size() > 0 and results[0].get("collider") == self:
			state_machine.register_click()
			AudioManager.play_sound(click_sound)
			
	state_machine.update(delta)
	heart_bar.value = state_machine.get_fill_percentage() * heart_bar.max_value

func _on_romance_start():
	animator.play_animation("idle", false)
	patrol.stop()

func _on_romance_success():
	set_process(false)
	patrol.stop()

	var follow_target = player.last_follower
	follower.enable_follow(follow_target, animator)
	heart_bar.visible = false
	player.last_follower = self

func _on_romance_failed():
	set_process(false)
	patrol.start()
	heart_bar.visible = false

func get_state_machine():
	return state_machine

func on_game_over():
	print("lover game over")
	set_process(false)
	animator.play_animation("idle", false)
