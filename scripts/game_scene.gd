extends Node2D

@export var time_limit: float = 60.0
@export var timer: Timer

@export var timer_label: Label

var total_lovers := 0
var romanced_lovers := 0
var game_over := false

func _ready():
	var lovers = get_tree().get_nodes_in_group("lovers")
	total_lovers = lovers.size()
	
	for lover in lovers:
		lover.state_machine.romance_success.connect(_on_lover_romanced)

	timer.wait_time = time_limit
	timer.start()

func _process(delta):
	if not game_over:
		var remaining = timer.time_left
		timer_label.text = "Time Left: " + str(int(remaining))
		

func _on_lover_romanced():
	if game_over:
		return

	romanced_lovers += 1
	print("Romanced:", romanced_lovers, "/", total_lovers)

	if romanced_lovers >= total_lovers:
		_trigger_win()

func _trigger_win():
	game_over = true
	print("YOU WIN!")

func _trigger_lose():
	game_over = true
	print("YOU LOSE!")

func _on_timer_timeout() -> void:
	if not game_over:
		_trigger_lose()
