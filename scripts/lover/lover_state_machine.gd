extends Node

class_name LoverStateMachine

signal romance_success
signal romance_failed
signal romance_started

var _fill = 1.0
var _active = false
var _required_clicks = 10
var _fill_time = 3.0

var _has_jealous_partner = false
var _extra_drain_multiplier = 1.0

func setup(clicks: int, time: float):
	_required_clicks = clicks
	_fill_time = time
	_fill = 0.3
	_active = false

func update(delta: float):
	if _active:
		_extra_drain_multiplier = 1.5 if _has_jealous_partner else 1.0
		_fill -= delta / (_fill_time / _extra_drain_multiplier)
		_fill = clamp(_fill, 0.0, 1.0)

		if _fill <= 0.0:
			_active = false
			print("Romance failed!")
			romance_failed.emit()

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
	romance_started.emit()
	_active = true
	print("Started romance!")
