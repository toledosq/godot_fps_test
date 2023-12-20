extends Node

signal weapon_changed(weapon_name)
signal weapon_ammo_changed(ammo_count)
signal reserve_ammo_changed(ammo_count)
signal display_alert_text(text)

signal give_weapon_to_player(weapon_resource)

func _ready():
	print("Event Bus: Initialized")
