extends Control

class_name HUD

@export var button_click_audio : AudioStream

@export var score_label : Label
@export var timer_label : Label
@export var points_label: Label

@export var romanced_label : Label
@export var ending_label : Label
@export var gameOver_anim : AnimationPlayer

var _current_lovers : int
var _total_lovers : int

var _current_points : int

func update_timer(seconds: float):
	var minutes := int(seconds) / 60
	var secs := int(seconds) % 60
	timer_label.text = "Time Left: %02d:%02d" % [minutes, secs]

func update_score(current: int, total: int):
	_current_lovers = current
	_total_lovers = total
	score_label.text = "Romanced: %d / %d" % [current, total]

func update_points(current_points: int):
	_current_points = current_points
	points_label.text = "Points: " + str(int(current_points))

func show_game_over():
	var romance_ratio := float(_current_lovers) / float(_total_lovers)
	var points_ratio := float(_current_points) / float(GameManager.max_possible_points)
	var combined_score := (romance_ratio + points_ratio) / 2.0

	var ending_title: String
	if combined_score >= 0.8:
		ending_title = "ending: heartbreaker"
	elif combined_score >= 0.3:
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
