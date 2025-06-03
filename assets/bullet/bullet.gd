extends Area3D
var speed =80
func _process(delta: float) -> void:
	position += transform.basis*Vector3(0,0,-speed) *delta
	pass


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemy"):
		body.damage()
		queue_free()
	if body.is_in_group("object"):
		queue_free()
	
	pass # Replace with function body.


func _on_timer_timeout() -> void:
	queue_free()
	pass # Replace with function body.
