extends Node

enum LoverStatus { UNSET = -1, FAILED, SUCCEEDED }

class LoverState:
	var status: int = LoverStatus.UNSET
	var can_be_clicked: bool = true
	var partner_ids: Array[String] = []
	var current_expression: String = ""

var _lover_states: Dictionary = {}

func _get_or_create_state(lover_id: String) -> LoverState:
	if not _lover_states.has(lover_id):
		_lover_states[lover_id] = LoverState.new()
	return _lover_states[lover_id]

func mark_failed(lover_id: String):
	_get_or_create_state(lover_id).status = LoverStatus.FAILED

func mark_succeeded(lover_id: String):
	_get_or_create_state(lover_id).status = LoverStatus.SUCCEEDED

func get_status(lover_id: String) -> int:
	return _get_or_create_state(lover_id).status

func set_can_be_clicked(lover_id: String, value: bool):
	_get_or_create_state(lover_id).can_be_clicked = value

func get_can_be_clicked(lover_id: String) -> bool:
	return _get_or_create_state(lover_id).can_be_clicked

func set_partners(lover_id: String, ids: Array[String]):
	_get_or_create_state(lover_id).partner_ids = ids.duplicate()

func get_partners(lover_id: String) -> Array[String]:
	return _get_or_create_state(lover_id).partner_ids.duplicate()

func set_expression(lover_id: String, value: String):
	_get_or_create_state(lover_id).current_expression = value

func get_expression(lover_id: String) -> String:
	return _get_or_create_state(lover_id).current_expression

func has_resolved(lover_id: String) -> bool:
	var state = _lover_states.get(lover_id)
	return state != null and state.status != LoverStatus.UNSET

func reset():
	_lover_states.clear()
