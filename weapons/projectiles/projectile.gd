class_name Projectile extends RigidBody3D

var damage: int = 0
var speed: int = 0
var prev_pos := Vector3()
var direction : Vector3
var is_hit := false
var debug_bullet := preload("res://objects/debug/debug_bullet.tscn")


func _ready() -> void:
	prev_pos = global_transform.origin


func _physics_process(delta: float) -> void:
	var new_pos : Vector3 = global_transform.origin - (direction * speed * delta)
	var query = PhysicsRayQueryParameters3D.create(prev_pos, new_pos)
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	
	var distance = prev_pos.distance_to(new_pos)
	
	if result:
		is_hit = true
		new_pos = result.position
		
		if result.collider.has_method("apply_impulse"):
			result.collider.apply_impulse(-transform.basis.z, transform.basis.z * speed)
		if result.collider.has_method("hit"):
			result.collider.hit(damage)
		
		# TODO: Hit Particle Effects
		create_hit_indicator(result.position)
		#mesh_instance_3d.hide()
		#hit_particles.global_position = new_pos
		#hit_particles.emitting = true
		#await get_tree().create_timer(1).timeout
		queue_free()

	prev_pos = new_pos


func create_hit_indicator(_position: Vector3) -> void:
	var hit_indicator = debug_bullet.instantiate()
	var world = get_tree().get_root().get_child(0)
	world.add_child(hit_indicator)
	hit_indicator.global_translate(_position)


func _on_timer_timeout() -> void:
	queue_free()
