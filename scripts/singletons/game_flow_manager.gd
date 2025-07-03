extends Node

var current_scene_path: String = ""
var persistent_nodes := []  # Player + romanced lovers

func init_game():
	current_scene_path = "res://scenes/level1_scene.tscn"
	load_scene(current_scene_path)

func load_next_level(path: String):
	current_scene_path = path
	load_scene(path)

func load_previous_level(path: String):
	current_scene_path = path
	load_scene(path)

func reload_current_level():
	load_scene(current_scene_path)

func load_scene(path: String):
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	
	persistent_nodes.clear()
	
	if GlobalGameState.player:
		persistent_nodes.append(GlobalGameState.player)
	
	persistent_nodes += GlobalGameState.romanced_lovers

	SceneLoader.transition_to(path, persistent_nodes)
