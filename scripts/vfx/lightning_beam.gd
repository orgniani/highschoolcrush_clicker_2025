extends Node2D

@export var segments: int = 10
@export var jaggedness: float = 10.0

@onready var line: Line2D = $Line2D

var to_node: Node2D = null

func _ready():
	set_process(false)
	visible = false
	line.default_color = Color(1, 0, 0, 1)

func activate():
	set_process(true)
	visible = true

func deactivate():
	set_process(false)
	visible = false

func _process(delta):
	if not visible:
		return

	if not is_instance_valid(to_node):
		print("To node invalid")
		deactivate()
		return

	var start_pos = Vector2.ZERO
	var end_pos = to_local(to_node.global_position)

	var points := []
	for i in range(segments + 1):
		var t = i / float(segments)
		var pos = start_pos.lerp(end_pos, t)

		if i != 0 and i != segments:
			pos += Vector2(randf_range(-jaggedness, jaggedness), randf_range(-jaggedness, jaggedness))

		points.append(pos)

	line.points = points
