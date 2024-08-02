extends RigidBody2D

const GRASS_PARTICLES = preload("res://particles/grass_particles.tscn")
var _grass : GPUParticles2D = null


func _ready() -> void:
	var node = Node.new()
	add_child(node)
	_grass = GRASS_PARTICLES.instantiate()
	node.add_child(_grass)


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if abs(state.angular_velocity) >= 5:
		var emit := false
		for i in state.get_contact_count():
			var obj = state.get_contact_collider_object(i)
			if obj and obj.get_collision_layer_value(1):
				emit = true
				_grass.global_position = state.get_contact_collider_position(i)
				_grass.rotation_degrees = clamp(-state.angular_velocity * 4.0, -90, 90)
		_grass.emitting = emit
	else:
		_grass.emitting = false
	pass
