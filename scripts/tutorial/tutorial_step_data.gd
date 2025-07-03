extends Resource
class_name TutorialStepData

@export var id: String
@export var text: String
@export var requires_continue: bool = true
@export var allow_player_movement: bool = false

@export var wait_for_romance: bool = false
@export var wait_for_seconds: float = -1.0
@export var wait_for_area_trigger: bool = false

@export var clickable_lover_ids: Array[String] = []
