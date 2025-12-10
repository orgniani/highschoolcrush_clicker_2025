extends Resource
class_name PickupConfig

@export var name : String
@export var description : String

@export var icon : Texture2D
@export var drop_chance : float = 0.0   # 0.0–1.0

@export_enum("BEET", "FISH", "CLOCK")
var pickup_type : String

func apply_effect():
	match pickup_type:
		"BEET":
			GameManager.add_click_bonus(0.5, 10.0)
		"FISH":
			GameManager.break_all_partners()
		"CLOCK":
			GameManager.add_time(30.0)
