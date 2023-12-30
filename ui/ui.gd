class_name UI extends CanvasLayer


@onready var animation_player = $AnimationPlayer
@onready var ammo_counter_label = %AmmoCounterLabel
@onready var ammo_reserve_counter_label = %AmmoReserveCounterLabel
@onready var alert_text_label = %AlertTextLabel
@onready var weapon_name_label = %WeaponNameLabel
@onready var debug_lines = %DebugLines


func _ready():
	print("UI: Connecting to EventBus")
	EventBus.weapon_changed.connect(update_weapon_name)
	EventBus.weapon_ammo_changed.connect(update_ammo_counter)
	EventBus.reserve_ammo_changed.connect(update_ammo_reserve_counter)
	EventBus.display_alert_text.connect(update_alert_text)
	EventBus.enemy_count_updated.connect(update_enemy_counter)
	EventBus.weapon_stack_changed.connect(update_weapon_stack)
	
	print("UI: Initializing")
	update_ammo_reserve_counter(Globals.player_ammo_reserve_current)
	update_weapon_name(Globals.player_current_weapon)
	update_enemy_counter(Globals.enemy_count)


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


func update_enemy_counter(count):
	add_debug_property("Enemies Spawned", count, 0)


func update_weapon_stack(weapon_stack: Array[WeaponResource]):
	var weapon_stack_string: String = ""
	for weapon in weapon_stack:
		weapon_stack_string += (weapon.weapon_name + "\n")
	
	add_debug_property("Weapon Stack", weapon_stack_string, 1)


func add_debug_property(title:String, value, order):
	var target
	target = debug_lines.find_child(title, true, false)
	if !target:
		target = Label.new()
		debug_lines.add_child(target)
		target.name = title
		target.text = title + ": " + str(value)
	elif visible:
		target.text = title + ": " + str(value)
		debug_lines.move_child(target, order)
