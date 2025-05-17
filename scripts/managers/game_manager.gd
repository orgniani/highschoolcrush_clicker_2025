extends Node

class_name GameManager

@export var time_limit: float = 60.0
@export var timer: Timer

var total_lovers := 0
var romanced_lovers := 0
var game_over := false

signal updated_score(current: int, total: int)
signal updated_timer(seconds_left: float)
signal game_won
signal game_lost

func _ready():
	var lovers = get_tree().get_nodes_in_group("lovers")
	total_lovers = lovers.size()

	for lover in lovers:
		if lover.has_method("get_state_machine"):
			var state_machine = lover.get_state_machine()
			
			if state_machine:
				state_machine.romance_success.connect(_on_lover_romanced)
				
			else:
				print("Warning: State machine was null")
		else:
			print("Warning: Lover missing get_state_machine().")

	timer.wait_time = time_limit
	timer.start()

func _process(delta):
	if not game_over:
		emit_signal("updated_timer", timer.time_left)

func _on_lover_romanced():
	if game_over:
		return

	romanced_lovers += 1
	emit_signal("updated_score", romanced_lovers, total_lovers)

	if romanced_lovers >= total_lovers:
		_trigger_win()

func _trigger_win():
	game_over = true
	emit_signal("game_won")

func _trigger_lose():
	game_over = true
	emit_signal("game_lost")

func _on_timer_timeout():
	if not game_over:
		_trigger_lose()
