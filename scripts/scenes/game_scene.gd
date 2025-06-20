extends Node2D

var player: CharacterBody2D
@export var game_manager: GameManager
@export var hud: HUD

var _initialized := false

func initialize(player_ref: CharacterBody2D) -> void:
	if _initialized: return
	_initialized = true

	player = player_ref

	var lovers = get_tree().get_nodes_in_group("lovers")

	game_manager.updated_score.connect(hud.update_score)
	game_manager.updated_timer.connect(hud.update_timer)

	if not game_manager.game_over_signal.is_connected(hud.show_game_over):
		game_manager.game_over_signal.connect(hud.show_game_over)

	if not game_manager.game_over_signal.is_connected(player.on_game_over):
		game_manager.game_over_signal.connect(player.on_game_over)

	hud.update_score(game_manager.romanced_lovers, game_manager.total_lovers)

	for lover in lovers:
		lover.player = player

		if not game_manager.game_over_signal.is_connected(lover.on_game_over):
			game_manager.game_over_signal.connect(lover.on_game_over)
