extends Resource
class_name TutorialStepData

@export var id: String
@export var text: String
@export var requires_continue: bool = true
@export var allow_player_movement: bool = false
@export var wait_for_romance: bool = false
@export var clickable_lover_ids: Array[String] = []

@export var wait_for_area_trigger: bool = false
