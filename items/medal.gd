@tool
extends Node2D

@export var disabled := false : set = _on_set_disabled


func on_grab():
	$AudioStreamPlayer2D.play()
	$Medal.visible = false
	$Area2D/CollisionShape2D.set_deferred(&"disabled", true)
	$CPUParticles2D.emitting = true
	Globals.score_medals += 1


func _on_audio_stream_player_2d_finished() -> void:
	queue_free()


func _on_set_disabled(value: bool) -> void:
	disabled = value
	$CPUParticles2D2.visible = not disabled
	$Medal.material.set_shader_parameter(&"disabled", disabled)
