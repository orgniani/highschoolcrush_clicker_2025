extends Node
class_name TutorialManager

signal show_text(text: String)
signal allow_player_movement(value: bool)
signal tutorial_finished

@export var tutorial_data: TutorialData
@export var player: CharacterBody2D

var _current_step := 0
var _waiting_for_continue := false

func start_tutorial():
	print("Tutorial steps count:", tutorial_data.steps.size())  # ✅ Add this
	_current_step = 0
	_process_current_step()

func _process_current_step():
	if _current_step >= tutorial_data.steps.size():
		tutorial_finished.emit()
		return

	var original_step = tutorial_data.steps[_current_step]
	var step = load(original_step.resource_path) as TutorialStepData

	show_text.emit(step.text)
	allow_player_movement.emit(step.allow_player_movement)

	if step.spawn_easy_lover:
		_spawn_easy_lover()
	if step.spawn_hard_lover:
		_spawn_hard_lover()

	if step.wait_for_romance:
		await _wait_for_romance()
		_next_step()
		return

	if step.requires_continue:
		_waiting_for_continue = true
	else:
		_next_step()


func on_continue_pressed():
	if _waiting_for_continue:
		_next_step()

func _next_step():
	_waiting_for_continue = false
	_current_step += 1
	_process_current_step()

func _wait_for_romance() -> void:
	var previous_count = GameManager.romanced_lovers
	while GameManager.romanced_lovers <= previous_count:
		await get_tree().process_frame

func _spawn_easy_lover():
	# emit a signal here or instance one manually
	pass

func _spawn_hard_lover():
	# Same as above
	pass
