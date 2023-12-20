class_name StaticTarget extends StaticBody3D

@onready var target_mesh = $".."
@onready var target_mesh_hit = $"../../TargetMeshHit"
@onready var timer = $"../../Timer"


var was_hit := false


func hit(_damage):
	if !was_hit:
		was_hit = true
		target_mesh.hide()
		target_mesh_hit.show()
		timer.start()


func _on_timer_timeout():
	target_mesh_hit.hide()
	target_mesh.show()
	was_hit = false
