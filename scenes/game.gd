extends Node2D

const GUI_PAUSE := preload("res://gui/pause.tscn")
const GUI_GAME_OVER := preload("res://gui/game_over.tscn")

var checkpoint := 0


func _ready() -> void:
	Globals.game_over.connect(_on_game_over)
	$Car.position.y = $Terrain.get_position_y($Car.position.x) - 150


func _process(_delta: float) -> void:
	var pos := get_viewport().get_camera_2d().global_position.x
	var point := floori(pos / 100)
	if point > checkpoint:
		Globals.score_distance += (point - checkpoint) * 10
		checkpoint = point
	
	if Input.is_action_just_pressed(&"ui_cancel"):
		if not get_tree().paused:
			get_tree().paused = true
			var gui_pause = GUI_PAUSE.instantiate()
			get_tree().root.add_child(gui_pause)


func _on_game_over() -> void:
	if not get_tree().paused:
		get_tree().paused = true
		var gui_game_over = GUI_GAME_OVER.instantiate()
		get_tree().root.add_child.call_deferred(gui_game_over)
