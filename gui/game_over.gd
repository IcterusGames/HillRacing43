extends CanvasLayer

@onready var game_over_label: Label = %GameOverLabel
@onready var distance_box: HBoxContainer = %DistanceBox
@onready var distance_label: Label = %DistanceLabel
@onready var coins_box: HBoxContainer = %CoinsBox
@onready var coins_label: Label = %CoinsLabel
@onready var jumps_box: HBoxContainer = %JumpsBox
@onready var jumps_label: Label = %JumpsLabel
@onready var backflips_box: HBoxContainer = %BackflipsBox
@onready var backflips_label: Label = %BackflipsLabel
@onready var your_score_box: HBoxContainer = %YourScoreBox
@onready var your_score_label: Label = %YourScoreLabel
@onready var retry_button: Button = %RetryButton
@onready var exit_button: Button = %ExitButton
@onready var medal_1: Node2D = $VBoxContainer/Control2/Medal1
@onready var medal_2: Node2D = $VBoxContainer/Control2/Medal2
@onready var medal_3: Node2D = $VBoxContainer/Control2/Medal3
@onready var medal_4: Node2D = $VBoxContainer/Control2/Medal4



func _ready() -> void:
	control_animate(game_over_label, 10, 0)
	control_animate(distance_box, 3, 0.5)
	control_animate(coins_box, 3, 0.6)
	control_animate(jumps_box, 3, 0.7)
	control_animate(backflips_box, 3, 0.8)
	control_animate(your_score_box, 5, 0.9)
	medal_1.disabled = Globals.score_medals < 1
	medal_2.disabled = Globals.score_medals < 2
	medal_3.disabled = Globals.score_medals < 3
	medal_4.disabled = Globals.score_medals < 4
	node2D_animate(medal_1, 35, 1.0)
	node2D_animate(medal_2, 35, 1.1)
	node2D_animate(medal_3, 35, 1.2)
	node2D_animate(medal_4, 35, 1.3)
	distance_label.text = str(Globals.score_distance)
	coins_label.text = str(Globals.score_coins)
	jumps_label.text = str(Globals.score_jump)
	backflips_label.text = str(Globals.score_backflip)
	var score := Globals.score_distance
	score += Globals.score_coins
	score += Globals.score_jump
	score += Globals.score_backflip
	score += Globals.score_medals * Globals.MEDAL_VALUE
	your_score_label.text = str(score)
	retry_button.grab_focus()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"ui_cancel"):
		if exit_button.has_focus():
			_on_exit_button_pressed()
		else:
			exit_button.grab_focus()


func control_animate(control : Control, rot_max : float, interval : float) -> void:
	control.pivot_offset = control.size / 2
	control.rotation_degrees = randf_range(-rot_max, rot_max)
	control.scale = Vector2.ZERO
	var tween := create_tween()
	tween.tween_interval(interval)
	tween.tween_property(control, ^"scale", Vector2.ONE, 0.75).set_trans(Tween.TRANS_ELASTIC)


func node2D_animate(node : Node2D, rot_max : float, interval : float) -> void:
	node.rotation_degrees = randf_range(-rot_max, rot_max)
	node.scale = Vector2.ZERO
	var tween := create_tween()
	tween.tween_interval(interval)
	tween.tween_property(node, ^"visible", true, 0.01)
	tween.tween_property(node, ^"scale", Vector2.ONE, 0.75).set_trans(Tween.TRANS_ELASTIC)


func _on_retry_button_pressed() -> void:
	Globals.new_game()
	get_tree().paused = false
	queue_free()


func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file(ProjectSettings.get(&"application/run/main_scene"))
	get_tree().paused = false
	queue_free()
