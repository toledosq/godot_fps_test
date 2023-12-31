extends Area3D


func _on_body_entered(body):
	print("%s fell off the map!" % body.name)
	if body.has_method("on_death"):
		body.on_death()
	else:
		body.queue_free()
