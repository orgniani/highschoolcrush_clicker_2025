extends Control

class_name HUD

@export var menu_scene : PackedScene

@export var score_label : Label
@export var timer_label : Label

@export var gameOver_label : Label
@export var gameOver_anim : AnimationPlayer

func update_timer(seconds: float):
	timer_label.text = "Time Left: " + str(int(seconds))

func update_score(current: int, total: int):
	score_label.text = "Romanced: %d / %d" % [current, total]

func show_game_over(text: String):
	gameOver_label.text = text
	print("game over text")
	gameOver_anim.play("pop_up")


func _on_back_button_pressed() -> void:
		print("Back to menu!")
		get_tree().change_scene_to_packed(menu_scene)
