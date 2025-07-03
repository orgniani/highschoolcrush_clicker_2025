extends Node2D

@export var game_scene_path : String
@export var player: CharacterBody2D
@export var hud: TutorialHUD
@export var tutorial_manager: TutorialManager

var _lover_map: Dictionary = {}

func _ready():
	tutorial_manager.show_text.connect(hud.on_show_text)
	tutorial_manager.allow_player_movement.connect(player.on_allow_movement)
	tutorial_manager.tutorial_finished.connect(hud.on_tutorial_finished)
	hud.continue_pressed.connect(tutorial_manager.on_continue_pressed)
	hud.skip_pressed.connect(_skip_tutorial)

	await _wait_for_all_lovers()
	tutorial_manager.clickable_lovers_changed.connect(_on_clickable_lovers_changed)
	tutorial_manager.start_tutorial()

func _skip_tutorial():
	GameManager.reset_game_state()
	GameManager.start_game()
	
	tutorial_manager.queue_free()
	player.on_allow_movement(true)
	GameFlowManager.load_scene(game_scene_path)
	
func _wait_for_all_lovers() -> void:
	var lovers := get_tree().get_nodes_in_group("lovers")

	while true:
		var all_ready := true
		for lover in lovers:
			if not lover.has_method("get"):
				continue
			var id = lover.get("lover_id")
			if id == "" or not LoverStateTracker._lover_states.has(id):
				all_ready = false
				break
		if all_ready:
			break
		await get_tree().process_frame
	
	_register_lovers_by_id()

func _register_lovers_by_id():
	for lover in get_tree().get_nodes_in_group("lovers"):
		if lover.has_method("get"):
			var id = lover.get("lover_id")
			if id != "":
				_lover_map[id] = lover

func _on_clickable_lovers_changed(ids: Array[String]):
	print("[TUTORIAL] Updating clickable lovers to:", ids)

	for id in _lover_map:
		var lover = _lover_map[id]
		lover._set_can_be_clicked(false)

	for id in ids:
		if _lover_map.has(id):
			_lover_map[id]._set_can_be_clicked(true)
