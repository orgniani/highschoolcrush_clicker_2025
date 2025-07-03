extends CanvasLayer

signal on_transition_finished

@onready var color_rect : ColorRect = $"ColorRect"
@onready var animator : AnimationPlayer = $"AnimationPlayer"

var _is_reversing := false  # ← Track direction

func _ready():
	color_rect.visible = false
	animator.animation_finished.connect(_on_animation_finished)

func transition():
	color_rect.visible = true
	_is_reversing = false
	animator.play("fade_to_black")

func _on_animation_finished(anim_name):
	if !_is_reversing:
		on_transition_finished.emit()
		_is_reversing = true
		animator.play_backwards("fade_to_black")
	else:
		color_rect.visible = false
