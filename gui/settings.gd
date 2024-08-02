extends CenterContainer

signal back_pressed()

@onready var fx_volume: HSlider = %FXVolume
@onready var music_volume: HSlider = %MusicVolume
@onready var full_screen_container: PanelContainer = %FullScreenContainer
@onready var full_screen_check: CheckButton = %FullScreenCheck
@onready var hdr_container: PanelContainer = %HDRContainer
@onready var hdr_check: CheckButton = %HDRCheck
@onready var back_button: Button = %BackButton


func _ready() -> void:
	set_process(false)
	fx_volume.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"FX")))
	music_volume.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"Music")))
	full_screen_check.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	hdr_check.button_pressed = get_viewport().use_hdr_2d


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"ui_cancel"):
		if back_button.has_focus():
			_on_back_button_pressed()
		else:
			back_button.grab_focus()


func _on_visibility_changed() -> void:
	set_process(visible)
	if visible:
		back_button.grab_focus()


func _on_fx_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(&"FX"), linear_to_db(value))


func _on_music_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(&"Music"), linear_to_db(value))


func _on_full_screen_check_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_full_screen_check_focus_entered() -> void:
	full_screen_container.modulate = Color.YELLOW


func _on_full_screen_check_focus_exited() -> void:
	full_screen_container.modulate = Color.WHITE


func _on_full_screen_check_mouse_entered() -> void:
	if not full_screen_check.has_focus():
		full_screen_container.modulate = Color(1, 1, 0.706)


func _on_full_screen_check_mouse_exited() -> void:
	if not full_screen_check.has_focus():
		full_screen_container.modulate = Color.WHITE


func _on_hdr_check_toggled(toggled_on: bool) -> void:
	get_viewport().use_hdr_2d = toggled_on


func _on_hdr_check_focus_entered() -> void:
	hdr_container.modulate = Color.YELLOW


func _on_hdr_check_focus_exited() -> void:
	hdr_container.modulate = Color.WHITE


func _on_hdr_check_mouse_entered() -> void:
	if not hdr_check.has_focus():
		hdr_container.modulate = Color(1, 1, 0.706)


func _on_hdr_check_mouse_exited() -> void:
	if not hdr_check.has_focus():
		hdr_container.modulate = Color.WHITE


func _on_back_button_pressed() -> void:
	Globals.save_config()
	back_pressed.emit()
