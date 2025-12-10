extends Node2D

@export var config : PickupConfig

signal picked_up(config: PickupConfig)

func _ready():
	$Sprite2D.texture = config.icon

func _on_area_2d_body_entered(body: Node2D) -> void:
	config.apply_effect()
	picked_up.emit(config)
	queue_free()
