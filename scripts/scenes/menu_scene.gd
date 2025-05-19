extends Control

@export var game_scene : PackedScene
@export var main_theme : AudioStream
@export var button_click : AudioStream

func _ready():
	AudioManager.play_music(main_theme)
	
func _on_start_button_pressed() -> void:
	print("Start Game!")
	_play_button_click_sound()
	get_tree().change_scene_to_packed(game_scene)
	
	pass


func _on_credit_button_pressed() -> void:
	_play_button_click_sound()
	pass


func _on_quit_button_pressed() -> void:
	_play_button_click_sound()
	get_tree().quit()
	pass

func _play_button_click_sound() -> void:
	AudioManager.play_sound(button_click)
