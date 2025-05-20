extends Control

@export var button_click_audio : AudioStream

func _on_back_button_pressed() -> void:
	_play_button_click_sound()
	visible = false;
	pass

func _play_button_click_sound() -> void:
	AudioManager.play_sound(button_click_audio)
