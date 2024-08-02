extends Node2D


func set_terrain(terrain) -> void:
	for node in $Stumps3.get_children():
		node.global_position.y = terrain.get_position_y(node.global_position.x) + 10
	for node in $Stumps2.get_children():
		node.global_position.y = terrain.get_position_y(node.global_position.x) + 10
	for node in $Stumps.get_children():
		node.global_position.y = terrain.get_position_y(node.global_position.x) + 10
	for node in $Logs.get_children():
		node.global_position.y = terrain.get_position_y(node.global_position.x) + 10
