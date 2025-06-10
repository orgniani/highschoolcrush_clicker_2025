extends Node

class_name LoverExpressions

@export var expression_node: TextureRect
@export var alerted_sprite: Texture2D
@export var love_sprite: Texture2D
@export var sad_sprite: Texture2D

func show_alerted():
	_set_expression(alerted_sprite)

func show_love():
	_set_expression(love_sprite)

func show_sad():
	_set_expression(sad_sprite)

func hide():
	expression_node.visible = false

func _set_expression(sprite: Texture2D):
	expression_node.texture = sprite
	expression_node.visible = true
