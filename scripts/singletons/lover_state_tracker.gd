extends Node

signal lover_state_changed(lover_id: String)

enum LoverStatus { UNSET = -1, FAILED, SUCCEEDED }

class LoverState:
	var status: int = LoverStatus.UNSET
	var can_be_clicked: bool = true
	var partner_ids: Array[String] = []
	var current_expression: String = ""
	var has_partner_override: bool = false

var _lover_states: Dictionary = {}

func _get_or_create_state(lover_id: String) -> LoverState:
	if not _lover_states.has(lover_id):
		_lover_states[lover_id] = LoverState.new()
	return _lover_states[lover_id]


# ------------------------------------------------------------------------------
# STATE-CHANGING FUNCTIONS (must emit signal)
# ------------------------------------------------------------------------------

func mark_failed(lover_id: String):
	_get_or_create_state(lover_id).status = LoverStatus.FAILED
	emit_signal("lover_state_changed", lover_id)

func mark_succeeded(lover_id: String):
	_get_or_create_state(lover_id).status = LoverStatus.SUCCEEDED
	emit_signal("lover_state_changed", lover_id)


func set_can_be_clicked(lover_id: String, value: bool):
	_get_or_create_state(lover_id).can_be_clicked = value
	emit_signal("lover_state_changed", lover_id)


func set_partners(lover_id: String, ids: Array[String]):
	var state := _get_or_create_state(lover_id)
	state.partner_ids = ids.duplicate()
	state.has_partner_override = true
	emit_signal("lover_state_changed", lover_id)


func set_expression(lover_id: String, value: String):
	_get_or_create_state(lover_id).current_expression = value
	emit_signal("lover_state_changed", lover_id)


# ------------------------------------------------------------------------------
# GETTERS (no signal)
# ------------------------------------------------------------------------------

func get_status(lover_id: String) -> int:
	return _get_or_create_state(lover_id).status

func get_can_be_clicked(lover_id: String) -> bool:
	return _get_or_create_state(lover_id).can_be_clicked

func get_partners(lover_id: String) -> Array[String]:
	return _get_or_create_state(lover_id).partner_ids.duplicate()

func has_partner_override(lover_id: String) -> bool:
	return _get_or_create_state(lover_id).has_partner_override

func get_expression(lover_id: String) -> String:
	return _get_or_create_state(lover_id).current_expression

func has_resolved(lover_id: String) -> bool:
	var state = _lover_states.get(lover_id)
	return state != null and state.status != LoverStatus.UNSET


# ------------------------------------------------------------------------------
# OTHER FUNCTIONS
# ------------------------------------------------------------------------------

func lock_all_lovers():
	print("[LOVER TRACKER] Locking lovers:", _lover_states.keys())
	for id in _lover_states.keys():
		set_can_be_clicked(id, false)
	# ^ Emits automatically because set_can_be_clicked emits


func reset():
	_lover_states.clear()
