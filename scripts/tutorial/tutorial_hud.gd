extends Control
class_name TutorialHUD

signal continue_pressed
signal skip_pressed

@export var dialogue_label: Label

var _typing := false
var _skip_requested := false
var _current_text := ""

func _on_continue_button_pressed() -> void:
	if _typing:
		_skip_requested = true
	else:
		continue_pressed.emit()

func _on_skip_button_pressed() -> void:
	AudioManager.play_sfx_by_key(AudioKeys.SFX.BUTTON_CLICK)
	skip_pressed.emit()

func on_tutorial_finished() -> void:
	skip_pressed.emit()

func on_show_text(text: String) -> void:
	if _typing:
		_skip_requested = true
		while _typing:
			await get_tree().process_frame

	_typing = true
	_skip_requested = false
	_current_text = text
	dialogue_label.text = ""

	await _type_text(text)

	_typing = false

func _type_text(text: String) -> void:
	for i in text.length():
		if _skip_requested:
			dialogue_label.text = text
			return
		dialogue_label.text += text[i]
		await get_tree().create_timer(0.03).timeout
