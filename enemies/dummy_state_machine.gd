extends Node3D

# STATES
enum { NONE, IDLE, ALERT, STUNNED }
var state = NONE
var state_locked := false

var target = null

@onready var ray_cast = $RayCast
@onready var animation_player = $EnemyDummyModel/AnimationPlayer
@onready var stun_timer = $StunTimer
@onready var alert_timer = $AlertTimer


func _ready():
	enter_idle_state()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if state != STUNNED:
		if Input.is_action_just_pressed("test_stun_enemy"):
			enter_stunned_state()
		elif target:
			if state != ALERT:
				enter_alert_state()
		#else:
			#if state != IDLE:
				#enter_idle_state()

	# Animations and behaviors go here
	match state:
		IDLE:
			pass
		ALERT:
			pass
		STUNNED:
			pass


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
	alert_timer.start(1.0)


func _on_stun_timer_timeout():
	print("%s exited stunned state" % self.name)
	if target:
		enter_alert_state()
	else:
		enter_idle_state()


func _on_alert_timer_timeout():
	if state != STUNNED and !target:
		enter_idle_state()
