extends Node
class_name LoverPartnerManager

@export var partners: Array[CharacterBody2D] = []

var owner_lover: CharacterBody2D = null
var lover_target: CharacterBody2D = null

func register_partner(partner: CharacterBody2D):
	if not partners.has(partner):
		partners.append(partner)
		_update_tracker()

func unregister_partner(partner: CharacterBody2D):
	if partners.has(partner):
		partners.erase(partner)
		_update_tracker()

func notify_romance_started(by: CharacterBody2D):
	var i := partners.size() - 1
	while i >= 0:
		var partner = partners[i]
		if not is_instance_valid(partner):
			partners.remove_at(i)
		else:
			if partner.has_method("_set_can_be_clicked"):
				partner._set_can_be_clicked(false)
			if partner.has_method("_on_partner_romance_started"):
				partner._on_partner_romance_started(lover_target)
		i -= 1

func notify_romance_ended(success: bool):
	var i := partners.size() - 1
	while i >= 0:
		var partner = partners[i]
		if not is_instance_valid(partner):
			partners.remove_at(i)
		else:
			if partner.has_method("_set_can_be_clicked"):
				partner._set_can_be_clicked(true)
			if partner.has_method("_on_partner_romance_ended"):
				partner._on_partner_romance_ended(!success)
			if success and partner.has_method("_on_breakup_from_partner"):
				partner._on_breakup_from_partner()
		i -= 1

func has_partners() -> bool:
	return partners.size() > 0

func clear_all_partners():
	if owner_lover == null:
		print("[PartnerManager] ERROR: missing owner_lover")
		return

	for partner in partners:
		var partner_manager = partner.get_node_or_null("Lover/LoverPartnerManager")
		if partner_manager:
			partner_manager.unregister_partner(owner_lover)
	partners.clear()
	_update_tracker()

func _update_tracker():
	if owner_lover and owner_lover.has_meta("lover_id"):
		var ids: Array[String] = []
		for partner in partners:
			if partner.has_meta("lover_id"):
				ids.append(partner.get_meta("lover_id"))
		LoverStateTracker.set_partners(owner_lover.get_meta("lover_id"), ids)
