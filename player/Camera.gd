extends Camera3D

const ADS_LERP = 20
const lerp_speed = 1

@onready var fps_rig = %FPSRig
@onready var default_pos = position

var ads_bob := 0.05
var default_bob := 0.2
var bob_amount := default_bob
var bob_freq := 0.02


func _physics_process(delta):
	bob($"../..".in_motion, delta)


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
