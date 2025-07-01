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

func start_tutorial():
	print("Tutorial steps count:", tutorial_data.steps.size())
	_current_step = 0
	LoverStateTracker.lock_all_lovers()
	_process_current_step()

func _process_current_step():
	if _current_step >= tutorial_data.steps.size():
		tutorial_finished.emit()
		return

	var original_step = tutorial_data.steps[_current_step]
	print("[TUTORIAL] → Loading step:", original_step.resource_path)

	var step = load(original_step.resource_path) as TutorialStepData
	print("[TUTORIAL] Step:", step.id)
	print("[TUTORIAL] Text:", step.text)

	show_text.emit(step.text)
	allow_player_movement.emit(step.allow_player_movement)
	clickable_lovers_changed.emit(step.clickable_lover_ids)

	if step.wait_for_romance and step.requires_continue:
		_waiting_for_continue = true
		await _wait_for_continue_or_romance()
		_next_step()
		return

	if step.wait_for_romance:
		await _wait_for_romance()
		_next_step()
		return

	if step.wait_for_area_trigger:
		return

	if step.requires_continue:
		_waiting_for_continue = true
	else:
		_next_step()

func _wait_for_continue_or_romance() -> void:
	var previous_count = GameManager.finished_lovers
	while is_inside_tree():
		if not _waiting_for_continue:
			break
		if GameManager.finished_lovers > previous_count:
			break
		await get_tree().process_frame

func _next_step():
	_waiting_for_continue = false
	_current_step += 1
	_process_current_step()

func on_continue_pressed():
	if _waiting_for_continue:
		_next_step()

func on_area_trigger_entered():
	var step = load(tutorial_data.steps[_current_step].resource_path) as TutorialStepData
	if step.wait_for_area_trigger:
		print("[TUTORIAL] Area trigger activated, continuing step:", step.id)
		_next_step()

func _wait_for_romance() -> void:
	var previous_count = GameManager.finished_lovers
	while is_inside_tree() and GameManager.finished_lovers <= previous_count:
		await get_tree().process_frame
