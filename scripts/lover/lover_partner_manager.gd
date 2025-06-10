extends Node

class_name LoverPartnerManager

@export var partners: Array[CharacterBody2D] = []

var owner_lover: CharacterBody2D = null

func register_partner(partner: CharacterBody2D):
	if not partners.has(partner):
		partners.append(partner)
		print(owner_lover.name, " registered ", partner.name)

func unregister_partner(partner: CharacterBody2D):
	if partners.has(partner):
		partners.erase(partner)
		print(owner_lover.name, " unregistered ", partner.name)

func notify_romance_started(by: CharacterBody2D):
	for partner in partners:
		if partner.has_method("_set_can_be_clicked"):
			partner._set_can_be_clicked(false)
			
		if partner.has_method("_on_partner_romance_started"):
			partner._on_partner_romance_started(by)

func notify_romance_ended(success: bool):
	for partner in partners:
		if partner.has_method("_set_can_be_clicked"):
			partner._set_can_be_clicked(true)

		if partner.has_method("_on_partner_romance_ended"):
			partner._on_partner_romance_ended(!success)

		if success and partner.has_method("_on_breakup_from_partner"):
			partner._on_breakup_from_partner()

func has_partners() -> bool:
	return partners.size() > 0

func clear_all_partners():
	if owner_lover == null:
		print("❌ ERROR: LoverPartnerManager has no owner_lover set!")
		return

	print("💔 Clearing partners for: ", owner_lover.name)

	for partner in partners:
		print(" → Breaking up with: ", partner.name)

		# Ask partners manager to forget us
		if partner.has_node("Lover/LoverPartnerManager"):
			var their_manager = partner.get_node("Lover/LoverPartnerManager") as LoverPartnerManager
			their_manager.unregister_partner(owner_lover)

		# Stop them from following
		if partner.has_node("Lover/LoverFollower"):
			var their_follower = partner.get_node("Lover/LoverFollower") as LoverFollower
			their_follower.disable_follow()

		# Visual feedback
		if partner.has_method("_on_breakup_from_partner"):
			partner._on_breakup_from_partner()

	partners.clear()
	print("✔ Done clearing all partners for:", owner_lover.name)
