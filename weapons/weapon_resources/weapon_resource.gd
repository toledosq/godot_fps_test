class_name WeaponResource extends ItemData

@export_category("Weapon Properties")
@export var weapon_name: String
@export var weapon_range: int
@export var weapon_damage: int
@export var rate_of_fire: int
@export var projectile_velocity: int

@export_category("Weapon Scenes")
@export var weapon_player_model: PackedScene
@export var weapon_world_model: PackedScene
@export var weapon_mesh: ArrayMesh
@export var projectile_scene: PackedScene

@export_category("Weapon Ammo")
@export_enum("handgun", "shotgun", "rifle", "launcher") var ammo_type
@export var magazine_size: int
@export var current_ammo_amount: int

@export_category("Weapon Animations")
@export var fire_animation: String = ""
@export var reload_animation_partial: String = ""
@export var reload_animation_full: String = ""
@export var equip_animation: String = ""
@export var unequip_animation: String = ""
@export var walk_animation: String = ""
@export var sprint_animation: String = ""
@export var idle_animation: String = ""
@export var reverse_equip_anim_for_unequip: bool = false

@export_category("Weapons SFX")
@export var fire_sfx: AudioStreamMP3
@export var reload_sfx: AudioStreamMP3

@export_category("Dynamic Recoil")
@export var dynamic_recoil := true
@export var recoil_rotation_x: Curve
@export var recoil_rotation_y: Curve
@export var recoil_rotation_z: Curve
@export var recoil_position_z: Curve
@export var recoil_amplitude := Vector3.ONE
@export var lerp_speed : float = 1
