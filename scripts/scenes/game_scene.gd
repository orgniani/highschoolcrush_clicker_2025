extends Node2D

@export var player : CharacterBody2D
@export var game_manager: GameManager
@export var hud : HUD

func _ready():
	var lovers = get_tree().get_nodes_in_group("lovers")
	
	game_manager.setup_lovers(lovers)
	game_manager.updated_score.connect(hud.update_score)
	game_manager.updated_timer.connect(hud.update_timer)
	game_manager.game_over_signal.connect(hud.show_game_over)

	hud.update_score(game_manager.romanced_lovers, game_manager.total_lovers)

	game_manager.game_over_signal.connect(player.on_game_over)

	for lover in lovers:
		game_manager.game_over_signal.connect(lover.on_game_over)
