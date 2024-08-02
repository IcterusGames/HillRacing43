extends Control

signal score_changed()
signal nitro_changed()
@warning_ignore("unused_signal")
signal game_over()

const MEDAL_VALUE: int = 10000

var score_distance := 0 : set = _on_set_score_distance
var score_coins := 0 : set = _on_set_score_coins
var score_jump := 0 : set = _on_set_score_jump
var score_backflip := 0 : set = _on_set_score_backflip
var score_medals := 0 : set = _on_set_score_medals
var nitro := 5.0 : set = _on_set_nitro


func _ready() -> void:
	load_config()


func save_config() -> void:
	var file := FileAccess.open("user://config.cfg", FileAccess.WRITE)
	if file == null:
		return
	var config := {
		"volume_music": AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"Music")),
		"volume_fx": AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"FX")),
		"fullscreen": DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN,
		"hdr": get_viewport().use_hdr_2d,
	}
	file.store_string(JSON.stringify(config))


func load_config() -> void:
	var file := FileAccess.open("user://config.cfg", FileAccess.READ)
	if file == null:
		# Configuración por defecto
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(&"Music"), linear_to_db(0.5))
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(&"FX"), linear_to_db(0.5))
		get_viewport().use_hdr_2d = true
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		return
	var config = JSON.parse_string(file.get_as_text())
	if config == null or typeof(config) != TYPE_DICTIONARY:
		return
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(&"Music"), config["volume_music"])
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(&"FX"), config["volume_fx"])
	if config["fullscreen"]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	if config.has("hdr"):
		get_viewport().use_hdr_2d = config["hdr"]


func new_game() -> void:
	score_distance = 0
	score_coins = 0
	score_jump = 0
	score_backflip = 0
	score_medals = 0
	nitro = 5.0
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_set_score_distance(value : int) -> void:
	score_distance = value
	score_changed.emit()


func _on_set_score_coins(value : int) -> void:
	score_coins = value
	score_changed.emit()


func _on_set_score_jump(value : int) -> void:
	score_jump = value
	score_changed.emit()


func _on_set_score_backflip(value : int) -> void:
	score_backflip = value
	score_changed.emit()


func _on_set_score_medals(value : int) -> void:
	score_medals = value
	score_changed.emit()


func _on_set_nitro(value : float) -> void:
	nitro = clampf(value, 0.0, 5.0)
	nitro_changed.emit()
