extends Area3D
var speed =80
func _process(delta: float) -> void:
	position += transform.basis*Vector3(0,0,-speed) *delta
	pass


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("headenemy"):
		var zombie = body.get_parent() 
		while zombie != null and not zombie.has_method("damage"):
			zombie = zombie.get_parent()

		if zombie and zombie.has_method("damage"):
			zombie.damage(50)

		queue_free()

	elif body.is_in_group("enemy"):
		if body.has_method("damage"):
			body.damage(20)
		queue_free()

	elif body.is_in_group("object"):
		queue_free()



func _on_timer_timeout() -> void:
	queue_free()
	pass # Replace with function body.
