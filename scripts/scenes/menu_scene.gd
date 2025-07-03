extends Control

@export var tutorial_scene_path : String
@export var credits_panel : Control

func _ready():
	AudioManager.play_music_by_key(AudioKeys.MUSIC.MAIN_THEME)

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
	AudioManager.play_sfx_by_key(AudioKeys.SFX.BUTTON_CLICK)
