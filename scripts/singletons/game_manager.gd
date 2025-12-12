extends Node

@export var total_lovers: int = 50
@export var max_possible_points: int = 70
@export var time_limit: float = 300.0
@export var timer: Timer

var _resolved_lovers: Dictionary = {}
var romanced_lovers := 0
var finished_lovers := 0
var game_over := false

var total_points: int = 0

var _click_bonus_active := false
var _click_bonus_multiplier := 1.0
var _click_bonus_timer := 0.0

signal updated_score(current: int, total: int)
signal updated_points(current: int)
signal updated_timer(seconds_left: float)
signal game_over_signal()
signal click_bonus_over_signal()

func _ready():
	timer.timeout.connect(_on_timer_timeout)

func _process(delta):
	if not game_over:
		updated_timer.emit(timer.time_left)

		if _click_bonus_active:
			_click_bonus_timer -= delta
			if _click_bonus_timer <= 0.0:
				_click_bonus_multiplier = 1.0
				_click_bonus_active = false
				click_bonus_over_signal.emit()

func start_game():
	reset_game_state()

	romanced_lovers = 0
	finished_lovers = 0
	_resolved_lovers.clear()
	total_points = 0
	game_over = false

	timer.wait_time = time_limit
	timer.paused = false # <-- asegúrate de despausar
	timer.start()

	updated_score.emit(romanced_lovers, total_lovers)
	updated_points.emit(total_points)

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
	
	print("Lover %s succeeded. Finished lovers: %d / %d" % [id, finished_lovers, total_lovers])
	
	var points = lover.points
	total_points += points
	updated_points.emit(total_points)
	
	updated_score.emit(romanced_lovers, total_lovers)
	
	AudioManager.play_sfx_by_key(AudioKeys.SFX.ROMANCE_SUCCESS)

	if finished_lovers >= total_lovers:
		_trigger_game_over()

func handle_lover_failed(lover: Node):
	if not lover.has_meta("lover_id"):
		push_warning("Lover missing _lover_id on failure!")
		return

	var id = lover.get_meta("lover_id")
	if game_over or _resolved_lovers.has(id):
		return

	_resolved_lovers[id] = true
	finished_lovers += 1

	print("Lover %s failed. Finished lovers: %d / %d" % [id, finished_lovers, total_lovers])
	AudioManager.play_sfx_by_key(AudioKeys.SFX.ROMANCE_FAIL)

	if finished_lovers >= total_lovers:
		_trigger_game_over()

func _trigger_game_over():
	if game_over:
		return
	game_over = true

	AudioManager.play_sfx_by_key(AudioKeys.SFX.GAME_OVER)
	game_over_signal.emit()

func reset_game_state():
	timer.stop()
	timer.paused = false

	GlobalGameState.romanced_lovers.clear()
	GlobalGameState.romanced_ids.clear()
	GlobalGameState.reset_player_last_follower()
	
	LoverStateTracker.reset()
	
	game_over = false

func _on_timer_timeout():
	if not game_over:
		_trigger_game_over()

# ---------------------------------------------------------
# PICKUP EFFECTS
# ---------------------------------------------------------

func add_click_bonus(bonus: float, duration: float):
	_click_bonus_multiplier += bonus
	_click_bonus_timer = duration
	_click_bonus_active = true
	print("Click bonus activated: +", bonus, " for ", duration, " seconds")

func add_time(seconds: float):
	timer.start(timer.time_left + seconds)
	print("Added time:", seconds)

func break_all_partners():
	print("Breaking all partners!")
	
	var lovers = get_tree().get_nodes_in_group("lovers")
	for lover in lovers:
		if lover.is_boss:
			continue

		if lover.partner_manager and lover.partner_manager.has_partners():
			if lover.has_method("_on_partner_romance_ended"):
				lover._on_partner_romance_ended(false)

			lover.partner_manager.notify_romance_ended(true)
			lover.partner_manager.clear_all_partners()
