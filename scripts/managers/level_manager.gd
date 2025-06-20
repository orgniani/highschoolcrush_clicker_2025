extends Node
class_name LevelManager

@export var player: CharacterBody2D
@export var level_nodes: Array[NodePath]
var _current_level_index := 0

func _ready():
	_assign_player_to_all_levels()
	set_active_level(_current_level_index)

func next_level():
	if _current_level_index + 1 < level_nodes.size():
		_current_level_index += 1
		set_active_level(_current_level_index)

func previous_level():
	if _current_level_index > 0:
		_current_level_index -= 1
		set_active_level(_current_level_index)

func set_active_level(index: int):
	for i in range(level_nodes.size()):
		var level = get_node(level_nodes[i])
		var active = (i == index)
		level.visible = active
		level.set_process(active)
		level.set_physics_process(active)

func _assign_player_to_all_levels():
	for path in level_nodes:
		var level = get_node_or_null(path)
		if not level:
			continue
	
		if level.has_method("initialize"):
			level.initialize(player)
