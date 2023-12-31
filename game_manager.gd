extends Node

@export var level_override: PackedScene

var current_level: Level


func _ready():
	EventBus.player_died.connect(on_player_death)
	load_level()


func load_level():
	if level_override.can_instantiate():
		var level = level_override.instantiate()
		add_child(level)
		current_level = level
		print("%s loaded" % current_level.name)


func on_player_death():
	print("You died")
	current_level.queue_free()
	load_level()
