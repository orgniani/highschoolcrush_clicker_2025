extends Control

class_name HUD

@export var button_click_audio : AudioStream

@export var score_label : Label
@export var timer_label : Label

@export var romanced_label : Label
@export var ending_label : Label
@export var gameOver_anim : AnimationPlayer

var _current_lovers : int
var _total_lovers : int

func update_timer(seconds: float):
	timer_label.text = "Time Left: " + str(int(seconds))

func update_score(current: int, total: int):
	_current_lovers = current
	_total_lovers = total
	score_label.text = "Romanced: %d / %d" % [current, total]

func show_game_over():
	var percentage: float = float(_current_lovers) / float(_total_lovers)
	var ending_title: String

	if percentage >= 0.8:
		ending_title = "ending: heartbreaker"
	elif percentage >= 0.3:
		ending_title = "ending: drama Maker"
	else:
		ending_title = "ending: flop Era"

	romanced_label.text = "You romanced %d out of %d students!" % [_current_lovers, _total_lovers]
	ending_label.text = ending_title
	gameOver_anim.play("pop_up")

func _on_back_button_pressed() -> void:
		print("Back to menu!")
		AudioManager.play_sound(button_click_audio)
		get_tree().change_scene_to_file("res://scenes/menu_scene.tscn")
