extends CanvasLayer

const HUD_MESSAGE_SCENE := preload("res://gui/misc/hud_message.tscn")

var _msg_jump_score = null
var _msg_backflip_score = null

@onready var hud_main: MarginContainer = %HudMain
@onready var progress_bar: TextureProgressBar = %ProgressBar
@onready var score_label: Label = %ScoreLabel


func _ready() -> void:
	Globals.game_over.connect(_on_game_over)
	Globals.score_changed.connect(_on_score_changed)
	Globals.nitro_changed.connect(_on_nitro_changed)


func _on_game_over():
	hud_main.visible = false


func _on_score_changed():
	var score := Globals.score_distance
	score += Globals.score_coins
	score += ceili(Globals.score_jump)
	score += ceili(Globals.score_backflip)
	score += Globals.score_medals * Globals.MEDAL_VALUE
	score_label.text = tr("SCORE") + ": " + str(score)


func _on_nitro_changed():
	progress_bar.value = Globals.nitro


func _on_car_jump_scored(score: int) -> void:
	if not is_instance_valid(_msg_jump_score) or not _msg_jump_score.is_running():
		_msg_jump_score = HUD_MESSAGE_SCENE.instantiate()
		hud_main.add_child(_msg_jump_score)
		_msg_jump_score.position = Vector2(300, 170)
		_msg_jump_score.set_title("JUMP")
	_msg_jump_score.set_message("+" + str(score))


func _on_car_jump_landed() -> void:
	_msg_jump_score = null


func _on_car_backflip_performed(multi: int) -> void:
	if not is_instance_valid(_msg_backflip_score) or not _msg_backflip_score.is_running():
		_msg_backflip_score = HUD_MESSAGE_SCENE.instantiate()
		hud_main.add_child(_msg_backflip_score)
		_msg_backflip_score.position = Vector2(450, 230)
		_msg_backflip_score.set_title("BACKFLIP")
	if multi == 1:
		_msg_backflip_score.set_title("BACKFLIP")
		_msg_backflip_score.set_message("+1000")
	else:
		_msg_backflip_score.set_title(tr("BACKFLIP") + " x" + str(multi))
		_msg_backflip_score.set_message("+" + str(1000 * multi))
