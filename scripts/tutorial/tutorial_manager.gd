extends Node
class_name TutorialManager

signal show_text(text: String)
signal allow_player_movement(value: bool)
signal tutorial_finished
signal clickable_lovers_changed(ids: Array[String])

@export var tutorial_data: TutorialData
@export var player: CharacterBody2D

var _current_step := 0
var _waiting_for_continue := false
var _waiting_for_area_trigger := false

func start_tutorial():
	_current_step = 0
	LoverStateTracker.lock_all_lovers()
	_process_current_step()
	
	print("[TUTORIAL] START!")

func _process_current_step():
	_waiting_for_continue = false
	_waiting_for_area_trigger = false

	if _current_step >= tutorial_data.steps.size():
		tutorial_finished.emit()
		return

	var original_step = tutorial_data.steps[_current_step]
	print("[TUTORIAL] → Loading step:", original_step.resource_path)

	var step = load(original_step.resource_path) as TutorialStepData
	#print("[TUTORIAL] Step:", step.id)
	#print("[TUTORIAL] Text:", step.text)
	#print("[TUTORIAL] wait_for_romance:", step.wait_for_romance)
	#print("[TUTORIAL] requires_continue:", step.requires_continue)
	#print("[TUTORIAL] wait_for_area_trigger:", step.wait_for_area_trigger)

	show_text.emit(step.text)
	allow_player_movement.emit(step.allow_player_movement)
	clickable_lovers_changed.emit(step.clickable_lover_ids)

	if step.wait_for_area_trigger:
		_waiting_for_area_trigger = true

	if step.requires_continue:
		_waiting_for_continue = true

	_wait_for_step_conditions(step)

func _wait_for_step_conditions(step: TutorialStepData) -> void:
	call_deferred("_wait_for_step_conditions_internal", step)

func _wait_for_step_conditions_internal(step: TutorialStepData) -> void:
	
	if step.wait_for_romance:
		var previous_count = GameManager.finished_lovers
		while is_inside_tree() and GameManager.finished_lovers <= previous_count:
			if step.requires_continue and not _waiting_for_continue:
				break
			await get_tree().process_frame
	
	elif step.requires_continue:
		while is_inside_tree() and _waiting_for_continue:
			await get_tree().process_frame
	
	elif step.wait_for_area_trigger:
		while is_inside_tree() and _waiting_for_area_trigger:
			await get_tree().process_frame

	_next_step()

func on_continue_pressed():
	if _waiting_for_continue:
		AudioManager.play_sfx_by_key(AudioKeys.SFX.BUTTON_CLICK)
		_waiting_for_continue = false

func on_area_trigger_entered():
	if not _waiting_for_area_trigger:
		return

	AudioManager.play_sfx_by_key(AudioKeys.SFX.BUTTON_CLICK)
	var step = load(tutorial_data.steps[_current_step].resource_path) as TutorialStepData

	_waiting_for_area_trigger = false

func _next_step():
	_waiting_for_continue = false
	_waiting_for_area_trigger = false
	_current_step += 1
	_process_current_step()
