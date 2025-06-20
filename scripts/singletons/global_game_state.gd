extends Node

var player: CharacterBody2D = null
var romanced_lovers: Array = []
var romanced_ids: Array[String] = []

func find_lover_by_id(id: String) -> CharacterBody2D:
	for node in get_tree().get_nodes_in_group("lovers"):
		if node.has_meta("lover_id") and node.get_meta("lover_id") == id:
			return node
	return null
