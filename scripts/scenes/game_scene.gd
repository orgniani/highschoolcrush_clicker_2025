extends Node2D

@export var player : CharacterBody2D
@export var hud : HUD

func _ready():
	var lovers = get_tree().get_nodes_in_group("lovers")
	
	GameManagerSingleton.updated_score.connect(hud.update_score)
	GameManagerSingleton.updated_timer.connect(hud.update_timer)
	GameManagerSingleton.game_over_signal.connect(hud.show_game_over)
	GameManagerSingleton.game_over_signal.connect(player.on_game_over)

	hud.update_score(GameManagerSingleton.romanced_lovers, GameManagerSingleton.total_lovers)

	for lover in lovers:
		GameManagerSingleton.game_over_signal.connect(lover.on_game_over)
