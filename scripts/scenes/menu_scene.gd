extends Control

@export var tutorial_scene_path : String
@export var credits_panel : Control

func _ready():
	AudioManager.play_music_by_key(AudioKeys.MUSIC.MAIN_THEME)

func _on_start_button_pressed() -> void:
	print("Start Game!")
	AudioManager.play_sfx_by_key(AudioKeys.SFX.BUTTON_CLICK)
	GameFlowManager.load_scene(tutorial_scene_path)
	pass

func _on_credit_button_pressed() -> void:
	AudioManager.play_sfx_by_key(AudioKeys.SFX.BUTTON_CLICK)
	credits_panel.visible = true;
	pass

func _on_mute_button_pressed() -> void:
	AudioManager.toggle_mute()
	pass
