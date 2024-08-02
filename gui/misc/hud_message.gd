extends Node2D

var _tween_init := create_tween()
var _is_running := true

@onready var _title_label: Label = $Control/TitleLabel
@onready var _msg_label: Label = $Control/MsgLabel
@onready var _life_timer: Timer = $LifeTimer


func _ready() -> void:
	rotation = randf_range(-0.174533, 0.174533)
	_title_label.rotation = randf_range(-0.0872665, 0.0872665)
	_msg_label.rotation = randf_range(-0.0872665, 0.0872665)
	scale = Vector2.ZERO
	_tween_init.tween_property(self, ^"scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_ELASTIC)


func set_title(title : String) -> void:
	_title_label.text = title


func set_message(message : String) -> void:
	_msg_label.text = message
	_life_timer.stop()
	_life_timer.start()
	if not _tween_init.is_running():
		var tween = create_tween()
		_msg_label.pivot_offset = _msg_label.size / 2
		tween.tween_property(_msg_label, ^"scale", Vector2.ONE * 1.5, 0.1).set_trans(Tween.TRANS_ELASTIC)
		tween.tween_property(_msg_label, ^"scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_ELASTIC)


func is_running() -> bool:
	return _is_running


func _on_life_timer_timeout() -> void:
	_is_running = false
	var tween := create_tween()
	tween.tween_property(self, ^"scale", Vector2.ZERO, 0.25).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_callback(queue_free)
