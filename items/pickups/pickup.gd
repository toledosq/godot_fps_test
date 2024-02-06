extends RigidBody3D

# Export slot for item assignment
@export var slot_data: SlotData
@onready var sprite_3d = $Sprite3D
@onready var collision_shape_3d = $CollisionShape3D


func _ready() -> void:
	if slot_data.item_data is ItemDataWeapon:
		# Create new MeshInstance3D to hold weapon mesh
		var mesh = MeshInstance3D.new()
		# Get mesh from weapon in slot
		var model = slot_data.item_data.weapon_resource.weapon_mesh
		# Set MeshInstance3D mesh to weapon mesh and add as child
		mesh.mesh = model
		add_child(mesh)
		# Generate collision shape from mesh
		collision_shape_3d.make_convex_from_siblings()
	else:
		sprite_3d.texture = slot_data.item_data.texture
		sprite_3d.visible = true


func interact():
	print(self, "interacted with")
	if Globals.current_player.inventory_data.pick_up_slot_data(slot_data):
	# If successful, just delete pickup
		queue_free()

