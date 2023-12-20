extends Node

var current_player: Player
var current_level: Level
var player_transform

var player_health: int:
	set(val):
		player_health = val
var player_armor: int:
	set(val):
		player_armor = val
var player_weapon_ammo: int:
	set(val):
		player_weapon_ammo = val
		EventBus.weapon_ammo_changed.emit(player_weapon_ammo)
var player_ammo_reserve_current: int:
	set(val):
		player_ammo_reserve_current = val
		EventBus.reserve_ammo_changed.emit(player_ammo_reserve_current)
var player_ammo_reserve_max: int
var player_current_weapon: String:
	set(val):
		player_current_weapon = val
		EventBus.weapon_changed.emit(player_current_weapon)

var weapon_resource_id_map = {
	"AK74M": "res://weapons/weapon_resources/ak74m.tres",
	"SHOTGUN": "res://weapons/weapon_resources/shotgun.tres",
	"UZI": "res://weapons/weapon_resources/uzi.tres"
}

func _ready():
	print("Globals: Initialized")

func get_weapon_resource_from_id(id: String):
	return weapon_resource_id_map[id]
