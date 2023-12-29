extends Node3D

# STATES
enum { NONE, IDLE, ALERT, STUNNED }
var state = NONE
var state_locked := false

@onready var ray_cast = $RayCast
@onready var animation_player = $EnemyDummyModel/AnimationPlayer


func _ready():
	enter_idle_state()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !state_locked:
		if Input.is_action_just_pressed("test_stun_enemy"):
			if state != STUNNED:
				enter_stunned_state()
		elif ray_cast.is_colliding():
			if state != ALERT:
				enter_alert_state()
		else:
			if state != IDLE:
				enter_idle_state()
		
		match state:
			IDLE:
				pass
			ALERT:
				pass
			STUNNED:
				pass


func enter_idle_state():
	print("%s Entered idle state" % self.name)
	state = IDLE


func enter_alert_state():
	print("%s Entered alert state" % self.name)
	state = ALERT


func enter_stunned_state():
	print("%s Entered stunned state" % self.name)
	state = STUNNED
	state_locked = true
	await get_tree().create_timer(1.0).timeout
	state_locked = false
