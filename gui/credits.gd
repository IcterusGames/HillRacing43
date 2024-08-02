extends CenterContainer

signal back_pressed()

@onready var back_button: Button = %BackButton


func _ready() -> void:
	set_process(false)


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


func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
	OS.shell_open(meta)


func _on_back_button_pressed() -> void:
	back_pressed.emit()
