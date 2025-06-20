extends StaticBody2D

@onready var _button_container: VBoxContainer = $"VBoxContainer"
@onready var _up_button: Button = $"VBoxContainer/UpButton"
@onready var _down_button: Button = $"VBoxContainer/DownButton"

@export var level_manager : LevelManager
@export var has_next_level: bool = true
@export var has_previous_level: bool = false

func _ready() -> void:
	_up_button.visible = has_next_level
	_down_button.visible = not has_previous_level
	_button_container.visible = false

func _on_up_button_pressed() -> void:
	level_manager.next_level()

func _on_down_button_pressed() -> void:
	level_manager.previous_level()

func _on_area_2d_body_entered(body: Node2D) -> void:
	_button_container.visible = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	_button_container.visible = false
