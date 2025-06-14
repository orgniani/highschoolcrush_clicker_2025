extends Node2D

@export var lifetime: float = 1.0
@export var rise_distance: float = 30.0
@export var ease_curve: float = 0.5

@onready var label: Label = $Label

var _elapsed: float = 0.0
var _start_position: Vector2

func _ready():
	visible = false
	set_process(false)

func activate():
	visible = true
	set_process(true)
	_elapsed = 0.0
	_start_position = position

func _process(delta):
	_elapsed += delta
	var progress = _elapsed / lifetime
	progress = clamp(progress, 0.0, 1.0)

	var eased_progress = ease(progress, ease_curve)

	position = _start_position + Vector2(0, -rise_distance * eased_progress)
	label.modulate.a = 1.0 - eased_progress

	if progress >= 1.0:
		visible = false
		set_process(false)
