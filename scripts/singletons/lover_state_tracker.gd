extends Node

enum LoverStatus { FAILED, SUCCEEDED }

var _lover_states: Dictionary = {}

func mark_failed(lover_id: String):
	_lover_states[lover_id] = LoverStatus.FAILED

func mark_succeeded(lover_id: String):
	_lover_states[lover_id] = LoverStatus.SUCCEEDED

func get_status(lover_id: String) -> int:
	# Return -1 if lover_id is unknown
	return _lover_states.get(lover_id, -1)

func has_resolved(lover_id: String) -> bool:
	return _lover_states.has(lover_id)

func get_total_registered() -> int:
	return _lover_states.size()

func get_total_succeeded() -> int:
	return _lover_states.values().count(LoverStatus.SUCCEEDED)

func get_total_failed() -> int:
	return _lover_states.values().count(LoverStatus.FAILED)
