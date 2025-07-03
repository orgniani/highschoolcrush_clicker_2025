extends Node

class_name LoverStateMachine

signal romance_success
signal romance_failed
signal romance_started

@export var base_drain_multiplier := 1.0
@export var first_partner_bonus := 0.5
@export var additional_partner_bonus := 0.25

var _fill = 1.0
var _active = false
var _required_clicks = 10
var _fill_time = 3.0

var _jealous_partner_count := 0
var _extra_drain_multiplier = 1.0

func setup(clicks: int, time: float):
	_required_clicks = clicks
	_fill_time = time
	_fill = 0.3
	_active = false

func set_jealous_partner_count(count: int):
	_jealous_partner_count = count

func update(delta: float):
	if _active:
		_extra_drain_multiplier = get_extra_drain_multiplier()
		_fill -= delta / (_fill_time / _extra_drain_multiplier)
		_fill = clamp(_fill, 0.0, 1.0)

		if _fill <= 0.0:
			_active = false
			print("Romance failed!")
			romance_failed.emit()

func get_extra_drain_multiplier() -> float:
	var extra := 0.0
	if _jealous_partner_count > 0:
		extra = first_partner_bonus
		if _jealous_partner_count > 1:
			extra += (_jealous_partner_count - 1) * additional_partner_bonus
	
	return base_drain_multiplier + extra

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
