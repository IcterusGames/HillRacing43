extends Node2D


func on_grab():
	$AudioStreamPlayer2D.play()
	$Coin.visible = false
	$Area2D/CollisionShape2D.set_deferred(&"disabled", true)
	$CPUParticles2D.emitting = true


func _on_audio_stream_player_2d_finished() -> void:
	queue_free()
