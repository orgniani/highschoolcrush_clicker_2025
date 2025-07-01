extends Area2D
class_name TutorialAreaTrigger

@export var tutorial_manager: TutorialManager

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and tutorial_manager:
		tutorial_manager.on_area_trigger_entered()
		queue_free()
