class_name Level extends Node3D

@export var background_noise_player: AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.current_level = self
