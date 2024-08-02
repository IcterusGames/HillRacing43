extends CanvasLayer

@onready var tab_container: TabContainer = %TabContainer
@onready var resume_button: Button = %ResumeButton
@onready var surrender_button: Button = %SurrenderButton


func _ready() -> void:
	resume_button.grab_focus()


func _process(_delta: float) -> void:
	if tab_container.current_tab == 0:
		if Input.is_action_just_pressed(&"ui_cancel"):
			if resume_button.has_focus():
				_on_resume_button_pressed()
			else:
				resume_button.grab_focus()


func _on_settings_button_pressed() -> void:
	tab_container.current_tab = 1


func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	queue_free()


func _on_surrender_button_pressed() -> void:
	get_tree().paused = false
	queue_free()
	Globals.game_over.emit()


func _on_exit_button_pressed() -> void:
	get_tree().paused = false
	queue_free()
	get_tree().change_scene_to_file(ProjectSettings.get(&"application/run/main_scene"))


func _on_gui_settings_back_pressed() -> void:
	resume_button.grab_focus.call_deferred()
	tab_container.current_tab = 0
