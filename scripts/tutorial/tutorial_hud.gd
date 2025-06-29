extends Control
class_name TutorialHUD

signal continue_pressed
signal skip_pressed

@export var dialogue_label: Label

var _typing := false

func _on_continue_button_pressed() -> void:
	if _typing:
		return
	continue_pressed.emit()

func _on_skip_button_pressed() -> void:
	skip_pressed.emit()

func on_show_text(text: String):
	_typing = true
	dialogue_label.text = ""
	for i in text.length():
		dialogue_label.text += text[i]
		await get_tree().create_timer(0.03).timeout
	_typing = false
