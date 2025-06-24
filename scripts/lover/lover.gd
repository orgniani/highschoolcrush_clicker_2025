extends CharacterBody2D

@export var player: CharacterBody2D
@export var config: HumanConfig
@export var click_sound: AudioStream
@export var required_clicks: int = 10
@export var fill_time: float = 3.0
@export var is_boss: bool = false
@export var lover_id: String = ""

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
var _has_succeeded := false
var _state_machine_connected := false

var _current_lover: CharacterBody2D
var _lover_id: String = ""

func _ready():
	_assign_lover_id()
	_restore_state()
	_setup_lifecycle()
	
	if !is_boss:
		animator.modulate = Color.WHITE

func _assign_lover_id():
	if lover_id.is_empty():
		push_error("Lover has no lover_id assigned!")
		lover_id = name

	_lover_id = lover_id
	set_meta("lover_id", _lover_id)

func _restore_state():
	var status = LoverStateTracker.get_status(_lover_id)

	match status:
		LoverStateTracker.LoverStatus.SUCCEEDED:
			_has_succeeded = true
			queue_free()
			return
		LoverStateTracker.LoverStatus.FAILED:
			_has_failed = true
			_restore_failed_state()

	var can_click = LoverStateTracker.get_can_be_clicked(_lover_id)
	_can_be_clicked = can_click
	_set_can_be_clicked(can_click)

	for partner_id in LoverStateTracker.get_partners(_lover_id):
		var partner = GlobalGameState.find_lover_by_id(partner_id)
		if partner:
			partner_manager.register_partner(partner)

	match LoverStateTracker.get_expression(_lover_id):
		"love": expressions.show_love()
		"sad": expressions.show_sad()
		"alerted": expressions.show_alerted()
		_: expressions.hide()

	_setup_state_machine()

func _setup_lifecycle():
	animator.apply_config(config)
	animator.play_animation("idle", false)
	heart_bar.max_value = required_clicks
	heart_bar.visible = false
	patrol.setup(animator, self)
	partner_manager.owner_lover = self
	partner_manager.lover_target = self
	set_process(true)

func _setup_state_machine():
	state_machine.setup(required_clicks, fill_time)
	state_machine.romance_success.connect(_on_romance_success)
	state_machine.romance_failed.connect(_on_romance_failed)
	state_machine.romance_started.connect(_on_romance_start)

func _restore_failed_state():
	_has_failed = true
	_can_be_clicked = false
	patrol.start()
	expressions.show_love()

func _process(delta):
	if not _state_machine_connected:
		if not state_machine.romance_failed.is_connected(_on_romance_failed):
			_setup_state_machine()
			_state_machine_connected = true

	var status = LoverStateTracker.get_status(_lover_id)
	if Input.is_action_just_pressed("click") and _can_be_clicked and status != LoverStateTracker.LoverStatus.FAILED:
		var mouse_pos = get_global_mouse_position()
		var query := PhysicsPointQueryParameters2D.new()
		query.position = mouse_pos
		query.collide_with_areas = true
		var result = get_world_2d().direct_space_state.intersect_point(query, 1)

		if result and result[0].get("collider") == self:
			state_machine.register_click()
			AudioManager.play_sound(click_sound)

	heart_bar.value = state_machine.get_fill_percentage() * heart_bar.max_value

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
	print("Romance success for:", _lover_id)
	LoverStateTracker.mark_succeeded(_lover_id)
	_has_succeeded = true
	set_process(false)
	patrol.stop()
	var follow_target = GlobalGameState.player.last_follower
	follower.enable_follow(follow_target, self)
	GlobalGameState.player.last_follower = self
	heart_bar.visible = false
	GlobalGameState.romanced_lovers.append(self)
	GlobalGameState.romanced_ids.append(_lover_id)
	GameManager.handle_lover_success(self)
	expressions.hide()
	if partner_manager.has_partners():
		partner_manager.notify_romance_ended(true)
		partner_manager.clear_all_partners()

	if state_machine.romance_failed.is_connected(_on_romance_failed):
		state_machine.romance_failed.disconnect(_on_romance_failed)
	if state_machine.romance_success.is_connected(_on_romance_success):
		state_machine.romance_success.disconnect(_on_romance_success)

func _on_romance_failed(from_partner := false):
	if _has_failed:
		return
	_has_failed = true

	print("Romance failed for:", _lover_id)

	LoverStateTracker.mark_failed(_lover_id)
	LoverStateTracker.set_can_be_clicked(_lover_id, false)
	GameManager.handle_lover_failed(self)

	set_process(false)
	patrol.start()
	heart_bar.visible = false
	_can_be_clicked = false

	var had_partners = partner_manager.has_partners()

	if had_partners:
		partner_manager.notify_romance_ended(false)
		partner_manager.clear_all_partners()
		expressions.show_love()
		LoverStateTracker.set_expression(_lover_id, "love")
	else:
		expressions.hide()
		LoverStateTracker.set_expression(_lover_id, "")

	if from_partner:
		return

func _on_partner_romance_started(romanced_lover: CharacterBody2D):
	if _has_succeeded:
		return
	_current_lover = romanced_lover
	patrol.stop()
	expressions.show_alerted()
	LoverStateTracker.set_expression(_lover_id, "alerted")
	var flip = (_current_lover.global_position - global_position).x < 0
	animator.play_animation("idle", flip)
	_spawn_lightning()
	jealous_popup.activate()

func _on_partner_romance_ended(failed: bool):
	if _has_succeeded:
		return
	patrol.start()
	lightning.deactivate()
	if failed:
		_on_romance_failed(true)
		expressions.show_love()
		LoverStateTracker.set_expression(_lover_id, "love")
	else:
		expressions.show_sad()
		LoverStateTracker.set_expression(_lover_id, "sad")

func _spawn_lightning():
	lightning.to_node = _current_lover.get_node("BeamToNode")
	lightning.activate()

func _set_can_be_clicked(value: bool):
	_can_be_clicked = value
	LoverStateTracker.set_can_be_clicked(_lover_id, value)

func get_state_machine():
	return state_machine

func on_game_over():
	set_process(false)
	heart_bar.visible = false
