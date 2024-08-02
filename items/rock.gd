extends RigidBody2D


func resize(new_scale : float):
	$CollisionPolygon2D.scale = Vector2(new_scale, new_scale)
