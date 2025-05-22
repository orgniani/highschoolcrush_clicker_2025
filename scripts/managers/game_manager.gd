extends Node

class_name GameManager

@export var game_over_sound : AudioStream
@export var romance_success_sound : AudioStream
@export var romance_failed_sound : AudioStream

@export var time_limit: float = 60.0
@export var timer: Timer

var total_lovers := 0
var romanced_lovers := 0
var finished_lovers := 0
var game_over := false

signal updated_score(current: int, total: int)
signal updated_timer(seconds_left: float)
signal game_over_signal()

func _ready():
	timer.wait_time = time_limit
	timer.start()

func setup_lovers(lovers: Array[Node]):
	total_lovers = lovers.size()

	for lover in lovers:
		if lover.has_method("get_state_machine"):
			var state_machine = lover.get_state_machine()
			
			if state_machine:
				state_machine.romance_success.connect(_on_lover_romanced)
				state_machine.romance_failed.connect(_on_lover_failed)	
			else:
				print("Warning: State machine was null")
		else:
			print("Warning: Lover missing get_state_machine().")

func _process(delta):
	if not game_over:
		updated_timer.emit(timer.time_left)

func _on_lover_romanced():
	if game_over:
		return

	romanced_lovers += 1
	finished_lovers += 1
	updated_score.emit(romanced_lovers, total_lovers)

	if romanced_lovers >= total_lovers:
		_trigger_game_over()
	else:
		AudioManager.play_sound(romance_success_sound)

	_check_if_all_lovers_resolved()

func _on_lover_failed():
	if game_over:
		return

	finished_lovers += 1
	print("Lover failed. Finished lovers: %d / %d" % [finished_lovers, total_lovers])
	if finished_lovers >= total_lovers:
		_trigger_game_over()
	else:
		AudioManager.play_sound(romance_failed_sound)

	_check_if_all_lovers_resolved()

func _check_if_all_lovers_resolved():
	if finished_lovers >= total_lovers and romanced_lovers < total_lovers:
		_trigger_game_over()

func _trigger_game_over():
	game_over = true
	AudioManager.play_sound(game_over_sound)
	game_over_signal.emit()

func _on_timer_timeout():
	if not game_over:
		_trigger_game_over()
