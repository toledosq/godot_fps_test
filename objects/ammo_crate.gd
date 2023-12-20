class_name AmmoCrate extends StaticBody3D

@export var cooldown_time: float = 5

@onready var cd_timer = $CDTimer
@onready var audio_stream_player = $AudioStreamPlayer

var can_interact := true

# Called when the node enters the scene tree for the first time.
func _ready():
	cd_timer.wait_time = cooldown_time


func interact():
	if can_interact:
		# If ammo reserve already full, don't interact
		if Globals.player_ammo_reserve_current == Globals.player_ammo_reserve_max:
			return
		# Else, fill ammo reserve
		Globals.player_ammo_reserve_current = Globals.player_ammo_reserve_max
		
		# Play sound effect
		audio_stream_player.play()
		
		# Start cooldown
		can_interact = false
		cd_timer.start()
	else:
		# If crate interacted with recently, alert player of cooldown
		EventBus.display_alert_text.emit("Ammo Crate on cooldown: %s seconds" % str(ceil(cd_timer.time_left)))


func _on_cd_timer_timeout():
	can_interact = true
