extends Node

func transition_to(path: String, nodes_to_persist: Array):
	for node in nodes_to_persist:
		if node and node.get_parent():
			node.get_parent().remove_child(node)

	call_deferred("_change_scene", path, nodes_to_persist)

func _change_scene(path: String, nodes_to_persist: Array):
	await get_tree().change_scene_to_file(path)

	await get_tree().process_frame
	var root = get_tree().current_scene

	if root == null:
		await get_tree().process_frame
		root = get_tree().current_scene

	if root == null:
		push_error("Scene load failed!")
		return

	for node in nodes_to_persist:
		if node:
			root.add_child(node)
