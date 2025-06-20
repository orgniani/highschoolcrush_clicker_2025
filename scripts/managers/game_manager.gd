extends Node
class_name GameManager

@export var game_over_sound: AudioStream
@export var romance_success_sound: AudioStream
@export var romance_failed_sound: AudioStream

@export var time_limit: float = 60.0
@export var timer: Timer

var _registered_lovers: Dictionary = {}
var total_lovers := 0
var romanced_lovers := 0
var finished_lovers := 0
var game_over := false

signal updated_score(current: int, total: int)
signal updated_timer(seconds_left: float)
signal game_over_signal()

func _ready():
	timer.wait_time = time_limit
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _process(delta):
	if not game_over:
		updated_timer.emit(timer.time_left)

func register_lover(lover: Node):
	if not lover.has_meta("lover_id"):
		push_warning("Lover missing 'lover_id' meta!")
		return

	var id: String = lover.get_meta("lover_id")
	if _registered_lovers.has(id):
		return  # Already registered

	_registered_lovers[id] = {
		"node": lover,
		"resolved": false
	}

	total_lovers += 1

	if lover.has_method("get_state_machine"):
		var state_machine = lover.get_state_machine()
		if state_machine:
			state_machine.romance_success.connect(func(): _on_lover_romanced(id))
			state_machine.romance_failed.connect(func(): _on_lover_failed(id))
		else:
			print("Warning: State machine was null for lover %s" % id)
	else:
		print("Warning: Lover missing get_state_machine() for lover %s" % id)

func _on_lover_romanced(id: String):
	if game_over or !_registered_lovers.has(id): return
	if _registered_lovers[id]["resolved"]: return

	_registered_lovers[id]["resolved"] = true
	romanced_lovers += 1
	finished_lovers += 1

	updated_score.emit(romanced_lovers, total_lovers)

	if finished_lovers >= total_lovers:
		_trigger_game_over()
	else:
		AudioManager.play_sound(romance_success_sound)

func _on_lover_failed(id: String):
	if game_over or !_registered_lovers.has(id): return
	if _registered_lovers[id]["resolved"]: return

	_registered_lovers[id]["resolved"] = true
	finished_lovers += 1

	print("Lover %s failed. Finished lovers: %d / %d" % [id, finished_lovers, total_lovers])

	if finished_lovers >= total_lovers:
		_trigger_game_over()
	else:
		AudioManager.play_sound(romance_failed_sound)

func _trigger_game_over():
	if game_over:
		return
	game_over = true
	AudioManager.play_sound(game_over_sound)
	game_over_signal.emit()

func _on_timer_timeout():
	if not game_over:
		_trigger_game_over()
