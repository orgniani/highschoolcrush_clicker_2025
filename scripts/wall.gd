extends StaticBody2D

@export var next_level_path: String = "res://scenes/level2_scene.tscn"
@export var previous_level_path: String = "res://scenes/level1_scene.tscn"

@onready var _button_container : VBoxContainer = $"VBoxContainer"
@onready var _up_button : Button = $"VBoxContainer/UpButton"
@onready var _down_button : Button = $"VBoxContainer/DownButton"

func _ready() -> void:
	_up_button.visible = next_level_path != "" and ResourceLoader.exists(next_level_path)
	_down_button.visible = previous_level_path != "" and ResourceLoader.exists(previous_level_path)
	
	_button_container.visible = false

func _on_up_button_pressed() -> void:
	print("Up pressed!")
	if next_level_path != "":
		get_tree().change_scene_to_file(next_level_path)

func _on_down_button_pressed() -> void:
	print("Down pressed!")
	if previous_level_path != "":
		get_tree().change_scene_to_file(previous_level_path)


func _on_area_2d_body_entered(body: Node2D) -> void:
	_button_container.visible = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	_button_container.visible = false
