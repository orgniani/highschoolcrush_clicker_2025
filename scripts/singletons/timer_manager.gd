extends Node

signal time_updated(seconds_left: float)
signal time_over()

var time_left := 0.0
var _running := false

func start_timer(seconds: float):
	time_left = seconds
	_running = true

func _process(delta):
	if not _running: return

	time_left -= delta
	time_updated.emit(time_left)
	if time_left <= 0:
		_running = false
		time_over.emit()
