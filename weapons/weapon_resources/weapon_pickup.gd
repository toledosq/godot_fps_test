class_name WeaponPickup extends RigidBody3D

@export var weapon_resource_id: String
var weapon_resource: WeaponResource

func _ready():
	if !weapon_resource:
		weapon_resource = load(Globals.get_weapon_resource_from_id(weapon_resource_id))


func interact():
	print("%s was interacted with" % self.name)
	print("Giving %s to player" % weapon_resource.weapon_name)
	EventBus.give_weapon_to_player.emit(weapon_resource)
	queue_free()
