extends CharacterBody3D

# STATES
enum { NONE, IDLE, ALERT, STUNNED, ATTACKING }

var state = NONE
var state_locked := false

@export var move_speed: int = 2
@export var turn_speed: float = 2.0

@onready var ray_cast = $RayCast
@onready var animation_player = $AnimationPlayer
@onready var stun_timer = $StunTimer
@onready var alert_timer = $AlertTimer
@onready var eyes = $Eyes

var target = null
var target_last_position: Vector3

var can_attack := true


func _ready():
	enter_idle_state()


func _physics_process(delta):
	# State transitions
	if state != STUNNED:
		if Input.is_action_just_pressed("test_stun_enemy"):
			enter_stunned_state()
		elif target:
			if state != ALERT:
				enter_alert_state()
	
	match state:
		IDLE:
			pass
		ALERT:
			track_target()
			movement()
		STUNNED:
			pass


func movement():
	var move_to_pos = target.global_transform.origin if target else target_last_position
	var direction = -(global_transform.origin - move_to_pos).normalized()
	velocity = direction * move_speed
	move_and_slide()


func track_target():
	if target:
		# Look at target
		eyes.look_at(target.global_transform.origin, Vector3.UP)
		# rotate dummy body to target
		rotate_y(deg_to_rad(eyes.rotation.y * turn_speed))
		#global_rotate(Vector3(0,1,0), deg_to_rad(eyes.rotation.y * turn_speed))
	else:
		eyes.look_at(target_last_position)


func enter_idle_state():
	state = IDLE
	print("%s Entered idle state" % self.name)


func enter_alert_state():
	state = ALERT
	print("%s Entered alert state" % self.name)


func enter_stunned_state(seconds: float = 2.0):
	state = STUNNED
	print("%s Entered stunned state" % self.name)
	stun_timer.start(seconds)


func _on_sight_range_body_entered(body):
	print("%s detected body %s" % [self.name, body.name])
	target = body


func _on_sight_range_body_exited(body):
	print("%s no longer detecting %s" % [self.name, body.name])
	target_last_position = target.global_transform.origin
	target = null
	alert_timer.start(1.0)


func _on_stun_timer_timeout():
	print("%s exited stunned state" % self.name)
	if target:
		enter_alert_state()
	else:
		enter_idle_state()


func _on_alert_timer_timeout():
	# If stunned, stun timer timeout will handle state transition
	if state != STUNNED and !target:
		enter_idle_state()
