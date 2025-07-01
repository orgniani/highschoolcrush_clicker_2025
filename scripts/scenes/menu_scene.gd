extends Control

@export var tutorial_scene_path : String
@export var credits_panel : Control
@export var main_theme : AudioStream
@export var button_click_audio : AudioStream

func _ready():
	AudioManager.play_music(main_theme)

func _on_start_button_pressed() -> void:
	print("Start Game!")
	_play_button_click_sound()
	GameFlowManager.load_scene(tutorial_scene_path)
	pass

func _on_credit_button_pressed() -> void:
	_play_button_click_sound()
	credits_panel.visible = true;
	pass

func _on_mute_button_pressed() -> void:
	AudioManager.toggle_mute()
	pass

func _play_button_click_sound() -> void:
	AudioManager.play_sound(button_click_audio)
