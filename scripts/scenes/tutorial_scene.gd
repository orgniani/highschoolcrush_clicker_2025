extends Node2D

@export var game_scene : PackedScene
@export var player: CharacterBody2D
@export var hud: TutorialHUD
@export var tutorial_manager: TutorialManager

func _ready():
	tutorial_manager.show_text.connect(hud.on_show_text)
	tutorial_manager.allow_player_movement.connect(player._on_allow_movement)
	#tutorial_manager.tutorial_finished.connect(hud._on_tutorial_finished)

	hud.continue_pressed.connect(tutorial_manager.on_continue_pressed)
	hud.skip_pressed.connect(_skip_tutorial)
	
	await get_tree().process_frame
	tutorial_manager.start_tutorial()

func _skip_tutorial():
	get_tree().change_scene_to_packed(game_scene)
	GameManager.reset_game_state()
	GameManager.start_game()
	
