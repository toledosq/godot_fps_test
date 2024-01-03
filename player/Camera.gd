extends Camera3D

const ADS_LERP = 20
const lerp_speed = 1

@export var recoil_rotation_x: Curve
@export var recoil_rotation_y: Curve
@export var recoil_rotation_z: Curve
@export var recoil_position_z: Curve
@export var recoil_amplitude := Vector3.ONE

@onready var fps_rig = %FPSRig
@onready var default_pos = position

var ads_bob := 0.05
var default_bob := 0.2
var bob_amount := default_bob
var bob_freq := 0.02

var current_time := 0.0
var return_position : Vector3
var return_rotation : Vector3
var target_rot: Vector3
var target_pos: Vector3
var recoil_amplitude_modifier := 1.0


func _physics_process(delta):
	bob($"../..".in_motion, delta)
	lerp_recoil(delta)


func sway(sway_amount):
	fps_rig.position.y += sway_amount.y * 0.0001
	fps_rig.position.x -= sway_amount.x * 0.0001


func bob(in_motion, delta):
	if in_motion:
		fps_rig.position.y = lerp(fps_rig.position.y, default_pos.y + sin(Time.get_ticks_msec() * bob_freq) * bob_amount, delta)
		fps_rig.position.x = lerp(fps_rig.position.x, default_pos.x + sin(Time.get_ticks_msec() * bob_freq * 0.5) * bob_amount, delta)
	else:
		fps_rig.position.y = lerp(fps_rig.position.y, 0.0, delta*10)
		fps_rig.position.x = lerp(fps_rig.position.x, 0.0, delta*10)


func lerp_recoil(delta: float) -> void:
	# If weapon just fired
	if current_time < 0.05:
		# Increment timer
		current_time += delta
		
		# Lerp to the rotation/position given by the apply_recoil function
		position.z = lerp(position.z, target_pos.z, lerp_speed * delta)
		rotation.z = lerp(rotation.z, target_rot.z, lerp_speed * delta)
		rotation.x = lerp(rotation.x, target_rot.x, lerp_speed * delta)

		# Adjust target rotation/position for next physics tic
		target_rot.z = recoil_rotation_z.sample(current_time) * recoil_amplitude.y * recoil_amplitude_modifier
		target_rot.x = recoil_rotation_x.sample(current_time) * -recoil_amplitude.x * recoil_amplitude_modifier
		target_pos.z = recoil_position_z.sample(current_time) * recoil_amplitude.z * recoil_amplitude_modifier
		
	else:
		# Lerp to the default rotation/position
		position.z = lerp(position.z, return_position.z, lerp_speed * delta * 8)
		rotation.z = lerp(rotation.z, return_rotation.z, lerp_speed * delta * 8)
		rotation.x = lerp(rotation.x, return_rotation.x, lerp_speed * delta * 8)

 
func apply_recoil() -> void:
	# Randomize which y direction the gun rotates
	recoil_amplitude.z *= -1 if randf() > 0.6 else 1
	
	# Rotate
	target_rot.z = recoil_rotation_z.sample(0)
	target_rot.x = recoil_rotation_x.sample(0)
	#target_rot.y = current_weapon_resource.recoil_rotation_y.sample(0) * 0.1
	
	# Move gun backwards
	target_pos.z = recoil_position_z.sample(0)
	current_time = 0
