extends Node2D

@onready var parallax_2d: Parallax2D = $Parallax2D
@onready var parallax_2d_2: Parallax2D = $Parallax2D2


func _process(_delta: float) -> void:
	var offsetx = (get_viewport().get_camera_2d().global_position.x - global_position.x) * 0.01
	parallax_2d.screen_offset.x = offsetx
	parallax_2d_2.screen_offset.x = offsetx


func set_terrain(terrain) -> void:
	for node in $Trees.get_children():
		node.global_position.y = terrain.get_position_y(node.global_position.x) + 10
	for node in $Mushrooms.get_children():
		node.global_position.y = terrain.get_position_y(node.global_position.x) + 2
	for node in parallax_2d.get_children():
		node.global_position.y = terrain.get_position_y(node.global_position.x) + 15
	for node in parallax_2d_2.get_children():
		node.global_position.y = terrain.get_position_y(node.global_position.x) + 25
