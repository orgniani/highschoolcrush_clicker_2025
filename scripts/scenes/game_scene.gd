extends Node2D

@export var player : CharacterBody2D
@export var hud : HUD

func _ready():
	var lovers = get_tree().get_nodes_in_group("lovers")
	
	GameManager.updated_score.connect(hud.update_score)
	GameManager.updated_timer.connect(hud.update_timer)
	GameManager.updated_points.connect(hud.update_points)

	GameManager.game_over_signal.connect(hud.show_game_over)
	GameManager.game_over_signal.connect(player.on_game_over)

	hud.update_points(GameManager.total_points)
	hud.update_score(GameManager.romanced_lovers, GameManager.total_lovers)

	for lover in lovers:
		GameManager.game_over_signal.connect(lover.on_game_over)
