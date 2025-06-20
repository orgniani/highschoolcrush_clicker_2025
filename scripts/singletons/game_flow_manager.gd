extends Node

var current_scene_path: String = ""
var persistent_nodes := []  # Player + romanced lovers

func init_game():
	current_scene_path = "res://scenes/level1_scene.tscn"
	TimerManager.start_timer(60)
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
	_fail_unresolved_lovers_in_current_scene()

	persistent_nodes.clear()
	if GlobalGameState.player:
		persistent_nodes.append(GlobalGameState.player)
	persistent_nodes += GlobalGameState.romanced_lovers

	SceneLoader.transition_to(path, persistent_nodes)

func _fail_unresolved_lovers_in_current_scene():
	var lovers = get_tree().get_nodes_in_group("lovers")
	for lover in lovers:
		if lover.has_meta("lover_id"):
			var id = lover.get_meta("lover_id")
			if not LoverStateTracker.has_resolved(id):
				LoverStateTracker.mark_failed(id)
