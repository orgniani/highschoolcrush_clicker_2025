extends Node2D

@export var config : PickupConfig

func _ready():
	$Sprite2D.texture = config.icon

func _on_area_2d_body_entered(body: Node2D) -> void:
	#config.apply_effect()
	queue_free()
