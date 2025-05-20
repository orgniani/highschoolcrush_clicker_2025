extends Node

class_name LoverStateMachine

signal romance_success
signal romance_failed

var _fill = 1.0
var _active = false
var _required_clicks = 10
var _fill_time = 3.0

func setup(clicks: int, time: float):
	_required_clicks = clicks
	_fill_time = time
	_fill = 0.5
	_active = false

func update(delta: float):
	if _active:
		_fill -= delta / _fill_time
		_fill = clamp(_fill, 0.0, 1.0)

		if _fill <= 0.0:
			_active = false
			print("Romance failed!")
			romance_failed.emit();

func register_click():
	if not _active:
		_start_romance()

	_fill += 1.0 / float(_required_clicks)
	_fill = clamp(_fill, 0.0, 1.0)

	if _fill >= 1.0:
		_active = false
		print("Romance success!")
		romance_success.emit()

func get_fill_percentage() -> float:
	return _fill

func _start_romance():
	_active = true
	_fill = 0.5
	print("Started romance!")
