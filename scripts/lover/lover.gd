extends CharacterBody2D

@export var player : CharacterBody2D
@export var config: HumanConfig
@export var heart_bar : TextureProgressBar
@export var required_clicks: int = 10
@export var fill_time: float = 3.0

@onready var state_machine: LoverStateMachine = $LoverStateMachine
@onready var follower: LoverFollower = $LoverFollower
@onready var animator: HumanAnimator = $"HumanAnimator"

func _ready():
	animator.apply_config(config)
	animator.play_animation("idle", false)
	
	heart_bar.max_value = required_clicks
	
	set_process(true)
	state_machine.setup(required_clicks, fill_time)
	state_machine.romance_success.connect(_on_romance_success)

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
			
	state_machine.update(delta)
	heart_bar.value = state_machine.get_fill_percentage() * heart_bar.max_value

func _on_romance_success():
	set_process(false)
	var follow_target = player.last_follower
	follower.enable_follow(follow_target, animator)
	
	heart_bar.visible = false;
	player.last_follower = self
