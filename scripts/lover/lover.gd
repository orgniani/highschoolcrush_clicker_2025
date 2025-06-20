extends CharacterBody2D

# References
@export var player: CharacterBody2D
@export var config: HumanConfig
@export var click_sound: AudioStream

# Parameters
@export var required_clicks: int = 10
@export var fill_time: float = 3.0

@onready var state_machine: LoverStateMachine = $"Lover/LoverStateMachine"
@onready var follower: LoverFollower = $"Lover/LoverFollower"
@onready var patrol: LoverPatrol = $"Lover/LoverPatrol"
@onready var expressions: LoverExpressions = $"Lover/LoverExpressions"
@onready var partner_manager: LoverPartnerManager = $Lover/LoverPartnerManager

@onready var animator: HumanAnimator = $"HumanAnimator"
@onready var lightning: Node2D = $"LightningBeam"
@onready var jealous_popup: Node2D = $"JealousPopup"

@onready var heart_bar: TextureProgressBar = $"HeartBar"

var _can_be_clicked := true
var _has_failed := false
var _current_lover: CharacterBody2D
var _has_succeeded := false

var _lover_id: String = ""

func _ready():
	_assign_lover_id()

	var status = LoverStateTracker.get_status(_lover_id)

	if status == LoverStateTracker.LoverStatus.SUCCEEDED:
		queue_free()
		return
	elif status == LoverStateTracker.LoverStatus.FAILED:
		_restore_failed_state()

	animator.apply_config(config)
	animator.play_animation("idle", false)

	heart_bar.max_value = required_clicks
	heart_bar.visible = false
	expressions.hide()

	patrol.setup(animator, self)
	partner_manager.owner_lover = self
	partner_manager.lover_target = self

	set_process(true)
	state_machine.setup(required_clicks, fill_time)
	state_machine.romance_success.connect(_on_romance_success)
	state_machine.romance_failed.connect(_on_romance_failed)
	state_machine.romance_started.connect(_on_romance_start)

func _assign_lover_id():
	var scene_path := "unknown_scene"
	var current_scene = get_tree().current_scene
	if current_scene != null:
		scene_path = current_scene.scene_file_path

	var node_path = get_path()
	_lover_id = "%s::%s" % [scene_path, node_path]
	set_meta("lover_id", _lover_id)

func _restore_failed_state():
	_has_failed = true
	_can_be_clicked = false
	patrol.start()
	expressions.show_love()

func _process(delta):
	if Input.is_action_just_pressed("click") and _can_be_clicked:
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
	heart_bar.visible = true
	state_machine._has_jealous_partner = partner_manager.has_partners()
	if partner_manager.has_partners():
		partner_manager.notify_romance_started(self)

func _on_romance_success():
	LoverStateTracker.mark_succeeded(_lover_id)
	_has_succeeded = true
	set_process(false)
	patrol.stop()
	var follow_target = GlobalGameState.player.last_follower
	follower.enable_follow(follow_target, self)
	heart_bar.visible = false
	GlobalGameState.player.last_follower = self
	GlobalGameState.romanced_lovers.append(self)
	GlobalGameState.romanced_ids.append(_lover_id)
	expressions.hide()
	if partner_manager.has_partners():
		partner_manager.notify_romance_ended(true)
		partner_manager.clear_all_partners()

func _on_romance_failed(from_partner: bool = false):
	if _has_failed:
		return
	LoverStateTracker.mark_failed(_lover_id)
	_has_failed = true
	set_process(false)
	patrol.start()
	heart_bar.visible = false
	_can_be_clicked = false
	if from_partner:
		state_machine.romance_failed.emit()
	if partner_manager.has_partners() and not from_partner:
		partner_manager.notify_romance_ended(false)
		partner_manager.clear_all_partners()
		expressions.show_love()

func _on_partner_romance_started(romanced_lover: CharacterBody2D):
	if _has_succeeded:
		return
	_current_lover = romanced_lover
	patrol.stop()
	expressions.show_alerted()
	var direction = _current_lover.global_position - global_position
	var flip_left = direction.x < 0
	animator.play_animation("idle", flip_left)
	_spawn_lightning()
	jealous_popup.activate()

func _spawn_lightning():
	lightning.to_node = _current_lover.get_node("BeamToNode")
	lightning.activate()

func _on_partner_romance_ended(failed: bool):
	if _has_succeeded:
		return
	patrol.start()
	lightning.deactivate()
	if failed:
		_on_romance_failed(true)
		expressions.show_love()
	else:
		expressions.show_sad()

func _set_can_be_clicked(value: bool):
	_can_be_clicked = value

func get_state_machine():
	return state_machine

func on_game_over():
	set_process(false)
	heart_bar.visible = false
