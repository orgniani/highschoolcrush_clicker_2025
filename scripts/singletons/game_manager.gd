extends Node

@export var game_over_sound: AudioStream
@export var romance_success_sound: AudioStream
@export var romance_failed_sound: AudioStream

@export var total_lovers: int = 6
@export var time_limit: float = 60.0
@export var timer: Timer

var _resolved_lovers: Dictionary = {}
var romanced_lovers := 0
var finished_lovers := 0
var game_over := false

signal updated_score(current: int, total: int)
signal updated_timer(seconds_left: float)
signal game_over_signal()

func _ready():
	timer.timeout.connect(_on_timer_timeout)

func _process(delta):
	if not game_over:
		updated_timer.emit(timer.time_left)

func start_game():
	romanced_lovers = 0
	finished_lovers = 0
	_resolved_lovers.clear()
	game_over = false

	timer.stop()
	timer.paused = false
	timer.wait_time = time_limit
	timer.start()

	updated_score.emit(romanced_lovers, total_lovers)

func handle_lover_success(lover: Node):
	if not lover.has_meta("lover_id"):
		push_warning("Lover missing lover_id on success!")
		return

	var id = lover.get_meta("lover_id")
	if game_over or _resolved_lovers.has(id):
		return

	_resolved_lovers[id] = true
	romanced_lovers += 1
	finished_lovers += 1

	updated_score.emit(romanced_lovers, total_lovers)
	AudioManager.play_sound(romance_success_sound)

	if finished_lovers >= total_lovers:
		_trigger_game_over()

func handle_lover_failed(lover: Node):
	if not lover.has_meta("lover_id"):
		push_warning("Lover missing lover_id on failure!")
		return

	var id = lover.get_meta("lover_id")
	if game_over or _resolved_lovers.has(id):
		return

	_resolved_lovers[id] = true
	finished_lovers += 1

	print("Lover %s failed. Finished lovers: %d / %d" % [id, finished_lovers, total_lovers])
	AudioManager.play_sound(romance_failed_sound)

	if finished_lovers >= total_lovers:
		_trigger_game_over()

func _trigger_game_over():
	if game_over:
		return
	game_over = true

	AudioManager.play_sound(game_over_sound)
	game_over_signal.emit()

	_reset_game_state()

func _reset_game_state():
	timer.paused = true

	GlobalGameState.romanced_lovers.clear()
	GlobalGameState.romanced_ids.clear()

	LoverStateTracker.reset()
	
	game_over = false

func _on_timer_timeout():
	if not game_over:
		_trigger_game_over()
