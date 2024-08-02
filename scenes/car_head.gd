extends RigidBody2D

signal collided(globalpos : Vector2)


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	for i in state.get_contact_count():
		var obj = state.get_contact_collider_object(i)
		if obj and obj.get_collision_layer_value(4):
			continue
		collided.emit(state.get_contact_collider_position(i))
