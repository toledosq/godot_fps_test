extends Node

@export var current_level: PackedScene


func _ready():
	pass


func load_level():
	if current_level.can_instantiate():
		var level = current_level.instantiate()
		add_child(level)
