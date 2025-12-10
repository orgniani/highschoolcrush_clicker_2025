extends Node2D

@export var player : CharacterBody2D
@export var hud : HUD
@export var floor_name : String

@export var drop_point : Node2D
@export var pickup_scene : PackedScene
@export var pickup_configs : Array[PickupConfig]

func _ready():
	var lovers = get_tree().get_nodes_in_group("lovers")
	
	GameManager.updated_score.connect(hud.update_score)
	GameManager.updated_timer.connect(hud.update_timer)
	GameManager.updated_points.connect(hud.update_points)

	GameManager.game_over_signal.connect(hud.show_game_over)
	GameManager.game_over_signal.connect(player.on_game_over)
	
	GameManager.click_bonus_over_signal.connect(hud.show_click_bonus_over)

	hud.update_points(GameManager.total_points)
	hud.update_score(GameManager.romanced_lovers, GameManager.total_lovers)
	hud.update_floor_name(floor_name)
	
	try_spawn_pickup()

	for lover in lovers:
		GameManager.game_over_signal.connect(lover.on_game_over)

func try_spawn_pickup():
	var roll := randf()
	print("--- ROLL:", roll)

	var sorted_configs := pickup_configs.duplicate()
	sorted_configs.sort_custom(_sort_by_chance)

	var cumulative := 0.0

	for config in sorted_configs:
		var next: float = cumulative + config.drop_chance
		print(config.name, "range:", cumulative, "→", next)

		if roll <= next:
			print("RESULT:", config.name)

			var item = pickup_scene.instantiate()
			item.config = config
			item.position = drop_point.position
			add_child(item)
			
			item.picked_up.connect(hud.show_pickup_popup)
			return

		cumulative = next

	print("RESULT: nothing (roll > total probability)")

func _sort_by_chance(a, b) -> int:
	return int(a.drop_chance - b.drop_chance)
