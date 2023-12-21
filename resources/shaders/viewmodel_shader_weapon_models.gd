@tool
#Credit to 2nafish117
#https://github.com/2nafish117/godot-viewmodel-render-test

extends Node3D

@export var meshes_with_shader: Array[MeshInstance3D]
@export var viewmodelFOV : float = 50.0 :set = set_view_model_fov



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_view_model_fov(val: float):
	viewmodelFOV = val
	set_mesh_fov(viewmodelFOV)


func set_mesh_fov(val: float):
	for mesh in meshes_with_shader:
		if mesh != null:
			# For each material in the mesh
			for i in range(mesh.mesh.get_surface_count()):
				var mat: Material = mesh.get_active_material(i)
				if mat is ShaderMaterial:
					mat.set_shader_parameter("viewmodel_fov", val)
