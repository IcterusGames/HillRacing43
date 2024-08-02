extends RigidBody2D

signal jump_scored(score : int)
signal jump_landed()
signal backflip_performed(multi : int)

const PARTICLES_BANG := preload("res://particles/bang.tscn")

@export var TORQUE := 700.0
@export var AUTO_ADVANCE := false
@export var ENABLE_USER := true
@export var MUTE := false

var _pitch := 0.0
var _air_time := 0.0
var _air_score := 0
var _backflip := false
var _backflip_multi := 1

@onready var pin_rear: PinJoint2D = $PinJointRear
@onready var pin_front: PinJoint2D = $PinJointFront
@onready var mark_rear: Marker2D = $PinJointRear/Marker2D
@onready var mark_front: Marker2D = $PinJointFront/Marker2D
@onready var wheel_rear: RigidBody2D = $PinJointRear/WheelRear
@onready var wheel_front: RigidBody2D = $PinJointFront/WheelFront
@onready var head: RigidBody2D = $Head
@onready var audio_engine: AudioStreamPlayer = $AudioEngine
@onready var particle_nitrous: GPUParticles2D = $ParticleNitrous
@onready var body_head_limit: StaticBody2D = $BodyHeadLimit


func _physics_process(delta: float) -> void:
	if _pitch > 0:
		_pitch -= delta
	else:
		_pitch += delta
	_pitch += Input.get_action_strength(&"speed_up") * delta * 1.5
	_pitch -= Input.get_action_strength(&"speed_down") * delta * 1.5
	_pitch = clampf(_pitch, -1, 1)
	if MUTE:
		audio_engine.stop()
	audio_engine.pitch_scale = absf(_pitch) + 1.0
	
	# Score por saltos
	if not freeze and wheel_rear.get_contact_count() == 0 and wheel_front.get_contact_count() == 0:
		_air_time += delta
		if _air_time >= 0.5:
			_air_score += 50
			_air_time -= 0.5
			jump_scored.emit(_air_score)
	elif not freeze and _air_time > 0:
		jump_landed.emit()
		Globals.score_jump += _air_score
		_air_score = 0
		_air_time = 0.0
		_backflip_multi = 1
	
	# Score por volteretas
	if rotation_degrees > 160 and rotation_degrees < 200:
		if not _backflip:
			_backflip = true
			Globals.score_backflip += 1000 * _backflip_multi
			backflip_performed.emit(_backflip_multi)
			_backflip_multi += 1
	else:
		_backflip = false
	
	if AUTO_ADVANCE:
		wheel_rear.apply_torque_impulse(250)
		wheel_front.apply_torque_impulse(250)
	
	if ENABLE_USER:
		wheel_rear.apply_torque_impulse(TORQUE * Input.get_action_strength(&"speed_up"))
		wheel_front.apply_torque_impulse(TORQUE * Input.get_action_strength(&"speed_up"))
		wheel_rear.apply_torque_impulse(-TORQUE * Input.get_action_strength(&"speed_down"))
		wheel_front.apply_torque_impulse(-TORQUE * Input.get_action_strength(&"speed_down"))
		
		apply_torque_impulse(-1000.0 * Input.get_action_strength(&"turn_left"))
		apply_torque_impulse(1000.0 * Input.get_action_strength(&"turn_right"))
		
		wheel_rear.lock_rotation = Input.is_action_pressed(&"brake")
		wheel_front.lock_rotation = Input.is_action_pressed(&"brake")
		
		if Input.is_action_pressed(&"nitro"):
			if Globals.nitro > 0:
				Globals.nitro -= delta
				particle_nitrous.emitting = true
				var dir := pin_rear.global_position - mark_rear.global_position
				wheel_rear.apply_central_force(dir * 150)
				dir = pin_front.global_position - mark_front.global_position
				wheel_front.apply_central_force(dir * 150)
			else:
				particle_nitrous.emitting = false
		else:
			particle_nitrous.emitting = false


func _on_head_body_entered(body: Node) -> void:
	if body == body_head_limit:
		return
	set_deferred(&"freeze", true)
	wheel_front.set_deferred(&"freeze", true)
	wheel_rear.set_deferred(&"freeze", true)
	head.set_deferred(&"freeze", true)
	body.set_deferred(&"freeze", true)
	audio_engine.stop()
	Globals.game_over.emit()


func _on_head_collided(globalpos: Vector2) -> void:
	if has_meta(&"bang"):
		return
	set_meta(&"bang", true)
	var bang = PARTICLES_BANG.instantiate()
	add_child(bang)
	bang.global_position = globalpos


func _on_area_items_area_entered(area: Area2D) -> void:
	if not area.has_meta(&"type"):
		return
	if area.get_meta(&"type") == "nitro":
		Globals.nitro += 1.5
		area.get_parent().queue_free()
	if area.get_meta(&"type") == "coin":
		Globals.score_coins += 50
		area.get_parent().on_grab()
