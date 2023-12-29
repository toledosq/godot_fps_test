class_name WeaponManager extends Node3D

enum STATES { NONE, READY, NOTREADY }
var state: STATES

const ADS_LERP = 20

@export_category("Camera")
@export var player_camera: Camera3D

@export_category("Weapons")
@export var starting_weapons: Array[WeaponResource]
@export var ammo_reserve_MAX : int = 150
@export var ammo_reserve_current : int = 0:
	set(val):
		ammo_reserve_current = val
		Globals.player_ammo_reserve_current = ammo_reserve_current

@onready var fps_rig = get_node("%FPSRig")
@onready var camera = get_node("%Camera")

var debug_bullet := preload("res://objects/debug/debug_bullet.tscn")
var weapons_array: Array[WeaponResource] # Player weapons available
var current_weapon_idx = null # Array index
var current_weapon_resource: WeaponResource # Holds the weapon properties
var current_weapon_model: Weapon # Holds the weapon model and animations
var collision_exclusion := [] # Holds the currently instantiated projectiles for V2

var can_fire := true
var ads := false

# Dynamic Recoil vars
var return_position : Vector3
var return_rotation : Vector3
var target_rot: Vector3
var target_pos: Vector3
var current_time: float


func _ready() -> void:
	# Connect to Globals to receive ammo stats
	Globals.player_ammo_reserve_max = ammo_reserve_MAX
	Globals.player_ammo_reserve_current = ammo_reserve_current
	
	# Receive starting weapons
	for weapon in starting_weapons:
		receive_weapon(weapon)
	
	change_state(STATES.READY)


func change_state(_state: STATES) -> void:
	state = _state


func _process(delta: float) -> void:
	# Aim down sight
	if current_weapon_model:
		if ads:
			current_weapon_model.transform.origin = current_weapon_model.transform.origin.lerp(current_weapon_model.ads_position, ADS_LERP * delta)
			camera.bob_amount = camera.ads_bob
		else:
			current_weapon_model.transform.origin = current_weapon_model.transform.origin.lerp(current_weapon_model.player_camera_position, ADS_LERP * delta)
			camera.bob_amount = camera.default_bob


func _physics_process(delta: float) -> void:
	if current_weapon_model:
		if current_weapon_resource.dynamic_recoil:
			lerp_recoil(delta)


func lerp_recoil(delta: float) -> void:
	# If weapon just fired
	if current_time < 0.05:
		# Increment timer
		current_time += delta
		
		# Lerp to the rotation/position given by the apply_recoil function
		current_weapon_model.position.z = lerp(current_weapon_model.position.z, target_pos.z, current_weapon_resource.lerp_speed * delta)
		current_weapon_model.rotation.z = lerp(current_weapon_model.rotation.z, target_rot.z, current_weapon_resource.lerp_speed * delta)
		current_weapon_model.rotation.x = lerp(current_weapon_model.rotation.x, target_rot.x, current_weapon_resource.lerp_speed * delta)

		# Adjust target rotation/position for next physics tic
		target_rot.z = current_weapon_resource.recoil_rotation_z.sample(current_time) * current_weapon_resource.recoil_amplitude.y
		target_rot.x = current_weapon_resource.recoil_rotation_x.sample(current_time) * -current_weapon_resource.recoil_amplitude.x
		target_pos.z = current_weapon_resource.recoil_position_z.sample(current_time) * current_weapon_resource.recoil_amplitude.z
		
	else:
		# Lerp to the default rotation/position
		current_weapon_model.position.z = lerp(current_weapon_model.position.z, return_position.z, current_weapon_resource.lerp_speed * delta * 8)
		current_weapon_model.rotation.z = lerp(current_weapon_model.rotation.z, return_rotation.z, current_weapon_resource.lerp_speed * delta * 8)
		current_weapon_model.rotation.x = lerp(current_weapon_model.rotation.x, return_rotation.x, current_weapon_resource.lerp_speed * delta * 8)

 
func apply_recoil() -> void:
	# Randomize which y direction the gun rotates
	current_weapon_resource.recoil_amplitude.y *= -1 if randf() > 0.5 else 1
	
	# Rotate
	target_rot.z = current_weapon_resource.recoil_rotation_z.sample(0)
	target_rot.x = current_weapon_resource.recoil_rotation_x.sample(0)
	#target_rot.y = current_weapon_resource.recoil_rotation_y.sample(0) * 0.1
	
	# Move gun backwards
	target_pos.z = current_weapon_resource.recoil_position_z.sample(0)
	current_time = 0


#func resize_weapon_viewport():
	#weapon_sub_viewport.size = DisplayServer.window_get_size()


func receive_weapon(weapon_resource: WeaponResource, fast := false) -> void:
	weapon_resource = weapon_resource.duplicate(true)
	weapons_array.push_back(weapon_resource)
	equip_weapon(max(len(weapons_array) - 1, 0), fast)


func equip_weapon(arrayIndex: int, fast := false) -> void:
	if arrayIndex > len(weapons_array) - 1:
		print("WeaponManager: Invalid index passed to equip_weapon (%s)" % arrayIndex)
		return
	
	if arrayIndex == current_weapon_idx:
		print("Weapon already equipped")
		return
	
	var next_weapon = weapons_array[arrayIndex]
	change_state(STATES.NOTREADY)
	await unequip_weapon(fast)
	
	current_weapon_idx = arrayIndex
	current_weapon_resource = next_weapon
	current_weapon_model = current_weapon_resource.weapon_player_model.instantiate()
	
	# Move weapon model to player camera position
	current_weapon_model.position = current_weapon_model.player_camera_position
	current_weapon_model.rotation = current_weapon_model.player_camera_rotation
	
	# Define return positions
	return_position = current_weapon_model.player_camera_position if !ads else current_weapon_model.ads_position
	return_rotation = current_weapon_model.player_camera_rotation if !ads else Vector3.ZERO
	
	# Bring child into world
	fps_rig.add_child(current_weapon_model)
	
	# Send event alerts
	Globals.player_weapon_ammo = current_weapon_resource.current_ammo_amount
	Globals.player_current_weapon = current_weapon_resource.weapon_name
	
	# Start equip animation
	if !fast:
		current_weapon_model.animation_player.play(current_weapon_resource.equip_animation)
	
	# Wait for equip animation to finish
	if current_weapon_model.animation_player.is_playing():
		await current_weapon_model.animation_player.animation_finished
	
	# Allow player to fire weapon
	change_state(STATES.READY)


func unequip_weapon(fast: bool = false) -> void:
	if current_weapon_model == null:
		return
	
	# Change state to NONE
	change_state(STATES.NONE)
	
	if !fast:
		# Play unequip animation
		if current_weapon_resource.reverse_equip_anim_for_unequip:
			current_weapon_model.animation_player.play_backwards(current_weapon_resource.equip_animation)
		else:
			current_weapon_model.animation_player.play(current_weapon_resource.unequip_animation)
		
		if current_weapon_model.animation_player.is_playing():
			await current_weapon_model.animation_player.animation_finished
	
	# Clear current weapon data
	current_weapon_model.queue_free()
	current_weapon_model = null
	current_weapon_resource = null
	
	# If no weapons left in stack, inform UI
	if len(weapons_array) == 0:
		Globals.player_current_weapon = ""
		Globals.player_weapon_ammo = 0
	
	print("WeaponManager: Weapon unequipped")


func drop_weapon() -> void:
	print("WeaponManager: Dropping weapon")
	if current_weapon_model == null:
		print("WeaponManager: Drop failed -- no weapon equipped")
		return
	
	change_state(STATES.NONE)
	
	var weapon_drop: WeaponPickup = current_weapon_resource.weapon_world_model.instantiate()
	weapon_drop.weapon_resource = current_weapon_resource.duplicate(true)
	
	Globals.current_level.add_child(weapon_drop)
	weapon_drop.position = global_position + Vector3(0,1,-1)
	weapon_drop.apply_impulse(Vector3(0, 2, -5))
	
	var next_weapon_idx: int = current_weapon_idx - 1
	if next_weapon_idx < 0:
		next_weapon_idx = max(len(weapons_array) - 1, 0)

	unequip_weapon(true)
	weapons_array.remove_at(current_weapon_idx)
	current_weapon_idx = null
	equip_weapon(next_weapon_idx)


func reload_weapon() -> void:
	if !current_weapon_model:
		print("Cannot reload, no weapon equipped")
		return
	
	if state != STATES.READY:
		return
	
	if Globals.player_ammo_reserve_current > 0 and current_weapon_resource.current_ammo_amount < current_weapon_resource.magazine_size:
		var reload_amount = min(
			current_weapon_resource.magazine_size - current_weapon_resource.current_ammo_amount, 
			current_weapon_resource.magazine_size, 
			Globals.player_ammo_reserve_current)
	
		change_state(STATES.NOTREADY)
		
		# Play sound
		if current_weapon_model.reload_audio_player:
			current_weapon_model.reload_audio_player.play()
		
		current_weapon_model.animation_player.play(current_weapon_resource.reload_animation_full)
		await current_weapon_model.animation_player.animation_finished
		
		current_weapon_resource.current_ammo_amount += reload_amount
		Globals.player_ammo_reserve_current -= reload_amount
		
		EventBus.weapon_ammo_changed.emit(current_weapon_resource.current_ammo_amount)
		
		change_state(STATES.READY)


func fire_weapon() -> void:
	if !current_weapon_model:
		print("Cannot fire, no weapon equipped")
		return
	
	if state != STATES.READY:
		return
	
	change_state(STATES.NOTREADY)
	
	if current_weapon_resource.current_ammo_amount > 0:
		print("Shooting projectile")
		
		# TODO: Experimental: Create Node3D projectile
		# create_projectile()
		
		# launch projectile rigidbody
		launch_projectile()
		
		# Update ammo counter
		current_weapon_resource.current_ammo_amount -= 1
		EventBus.weapon_ammo_changed.emit(current_weapon_resource.current_ammo_amount)
		
		# Play sound
		if current_weapon_model.fire_audio_player:
			current_weapon_model.fire_audio_player.pitch_scale = randf_range(0.9, 1.05)
			current_weapon_model.fire_audio_player.play()
		
		# Apply recoil or use fire animation
		if current_weapon_resource.dynamic_recoil:
			apply_recoil()
			await get_tree().create_timer(1.0/(current_weapon_resource.rate_of_fire / 60.0)).timeout
		else:
			current_weapon_model.animation_player.play(current_weapon_resource.fire_animation, -1, current_weapon_resource.rate_of_fire / 60.0)
			await current_weapon_model.animation_player.animation_finished
	
	change_state(STATES.READY)
	print("Weapon ammo count: %s" % current_weapon_resource.current_ammo_amount)


# TODO: VERSION 1: Node3D, does own raycasting, uses basis for direction
func create_projectile() -> void:
	var projectile = current_weapon_resource.projectile_scene.instantiate()
	current_weapon_model.muzzle_marker.add_child(projectile)
	# Move projectile to the muzzle position
	projectile.position = current_weapon_model.muzzle_marker.global_position
	# Set the projectile's direction to THIS basis
	projectile.transform.basis = global_transform.basis
	projectile.speed = current_weapon_resource.projectile_velocity
	projectile.damage = current_weapon_resource.weapon_damage


# VERSION 2: RigidBody3D, raycast to target to determine direction
func launch_projectile() -> void:
	# Create a raycast from center camera to weapon range
	var camera_collision = get_camera_collision(current_weapon_resource.weapon_range)
	# Determine direction based on specified bullet spawn point
	var direction = (camera_collision - current_weapon_model.muzzle_marker.get_global_transform().origin).normalized()
	# Instantiate the current weapon's exported projectile scene
	var projectile = current_weapon_resource.projectile_scene.instantiate()
	
	# Add projectile to collision exclusion list for other projectiles
	# This prevents future projectile raycasts from colliding w/ this projectile
	# If they collide, then the raycast will be off-target
	collision_exclusion.push_back(projectile.get_rid())
	# Connect to tree_exited signal so the exclusion list doesn't grow too large
	projectile.tree_exited.connect(remove_exclusion.bind(projectile.get_rid()))
	
	# Bring child into the world
	current_weapon_model.muzzle_marker.add_child(projectile)
	projectile.transform.basis = global_transform.basis
	
	# Set projectile damage to weapon's damage property
	projectile.damage = current_weapon_resource.weapon_damage
	projectile.speed = current_weapon_resource.projectile_velocity
	
	# Set projectile velocity to weapon's projectile velocity property
	projectile.set_linear_velocity(direction * current_weapon_resource.projectile_velocity)


func remove_exclusion(projectile_RID: RID) -> void:
	collision_exclusion.erase(projectile_RID)


func get_camera_collision(distance) -> Vector3:
	var camera_ = get_viewport().get_camera_3d()
	var viewport_size = get_viewport().get_size()
	
	# Set raycast origin to center of viewport
	var ray_origin = camera_.project_ray_origin(viewport_size/2)
	# Set raycast end to the distance specified (weapon distance for hitscan, custom distance for projectile)
	var ray_end = ray_origin + camera_.project_ray_normal(viewport_size/2) * distance
	
	var new_intersection = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	new_intersection.set_exclude(collision_exclusion)
	var intersection: Dictionary = get_world_3d().direct_space_state.intersect_ray(new_intersection)
	
	# Detect if the ray is colliding with anything
	if not intersection.is_empty():
		# return the position of the collision
		var col_point = intersection.position
		create_hit_indicator(col_point)
		return col_point
	# If no collision, return the ray's end point for next tick
	else:
		return ray_end


func create_hit_indicator(_position: Vector3) -> void:
	var hit_indicator : Node3D= debug_bullet.instantiate()
	hit_indicator.modulate = Color(0.1,0.0,1.0)
	hit_indicator.set_texture(load("res://assets/prototype/crosshair135.png"))
	hit_indicator.transform.scaled(Vector3(0.5,0.5,0.5))
	var world = get_tree().get_root().get_child(0)
	world.add_child(hit_indicator)
	hit_indicator.global_translate(_position)
