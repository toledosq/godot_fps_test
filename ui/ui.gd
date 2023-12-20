class_name UI extends CanvasLayer


@onready var animation_player = $AnimationPlayer
@onready var ammo_counter_label = %AmmoCounterLabel
@onready var ammo_reserve_counter_label = %AmmoReserveCounterLabel
@onready var alert_text_label = %AlertTextLabel
@onready var weapon_name_label = %WeaponNameLabel


func _ready():
	print("UI: Connecting to EventBus")
	EventBus.weapon_changed.connect(update_weapon_name)
	EventBus.weapon_ammo_changed.connect(update_ammo_counter)
	EventBus.reserve_ammo_changed.connect(update_ammo_reserve_counter)
	EventBus.display_alert_text.connect(update_alert_text)
	
	print("UI: Initializing")
	update_ammo_reserve_counter(Globals.player_ammo_reserve_current)
	update_weapon_name(Globals.player_current_weapon)

func update_weapon_name(weapon_name):
	weapon_name_label.text = weapon_name


func update_ammo_counter(ammo_amount):
	ammo_counter_label.text = str(ammo_amount)


func update_ammo_reserve_counter(ammo_amount):
	ammo_reserve_counter_label.text = str(ammo_amount)


func update_alert_text(text):
	alert_text_label.text = text
	if animation_player.is_playing():
		animation_player.seek(0)
	animation_player.play("display_alert_text")
