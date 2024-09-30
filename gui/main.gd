extends Node2D

@onready var camera_2d: Camera2D = %Camera2D
@onready var terrain: Node2D = %Terrain
@onready var car: RigidBody2D = %Car
@onready var tab_container: TabContainer = %TabContainer
@onready var play_button: Button = %PlayButton
@onready var credits_button: Button = %CreditsButton
@onready var settings_button: Button = %SettingsButton
@onready var exit_button: Button = %ExitButton


func _ready() -> void:
	play_button.text = tr("PLAY")
	credits_button.text = tr("CREDITS")
	settings_button.text = tr("SETTINGS")
	exit_button.text = tr("EXIT")
	car.position.y = terrain.get_position_y(car.position.x) - 150
	play_button.grab_focus()


func _process(_delta: float) -> void:
	if car.position.x >= -600:
		camera_2d.position.x = car.position.x + 600
	if tab_container.current_tab == 0:
		if Input.is_action_just_pressed(&"ui_cancel"):
			if exit_button.has_focus():
				_on_exit_button_pressed()
			else:
				exit_button.grab_focus()


func _on_play_button_pressed() -> void:
	Globals.new_game()


func _on_credits_button_pressed() -> void:
	tab_container.current_tab = 2


func _on_settings_button_pressed() -> void:
	tab_container.current_tab = 1


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_settings_back_pressed() -> void:
	tab_container.current_tab = 0
	settings_button.call_deferred(&"grab_focus")


func _on_credits_back_pressed() -> void:
	tab_container.current_tab = 0
	credits_button.call_deferred(&"grab_focus")
