extends CharacterBody3D

# STATES
enum { NONE, IDLE, ALERT, STUNNED, ATTACKING }

var state = NONE
var state_locked := false

@export var move_speed: float = 2.0
@export var turn_speed: float = 2.0
@export var alert_cooldown: float = 2.0

@onready var nav_agent = $NavigationAgent3D
@onready var ray_cast = $RayCast
@onready var stun_timer = $StunTimer
@onready var alert_timer = $AlertTimer
@onready var eyes = $Eyes

var target = null
var target_last_position: Vector3

var can_attack := true


func _ready():
	enter_idle_state()


func _physics_process(_delta):
		
	# State transitions
	if state != STUNNED:
		if Input.is_action_just_pressed("test_stun_enemy"):
			enter_stunned_state()
		elif target:
			if state != ALERT:
				enter_alert_state()
		movement()
	
	match state:
		IDLE:
			pass
		ALERT:
			track_target()
		STUNNED:
			pass


func movement():
	if nav_agent.is_navigation_finished():
		return
		
	var direction = -(global_transform.origin - target_last_position).normalized()
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - global_transform.origin).normalized() * move_speed
	
	if not is_on_floor():
		new_velocity.y -= Globals.gravity
	
	# Move and Slide called on velocity computed
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else:
		_on_navigation_agent_3d_velocity_computed(new_velocity)


func track_target():
	if target:
		# Get target last position
		target_last_position = target.global_transform.origin
		nav_agent.set_target_position(target_last_position)
		# Look at target
		eyes.look_at(target_last_position, Vector3.UP)
	else:
		eyes.look_at(target_last_position)
	
	rotate_y(deg_to_rad(eyes.rotation.y * turn_speed))


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
	target = null
	alert_timer.start(alert_cooldown)


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


func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	velocity = safe_velocity
	move_and_slide()
