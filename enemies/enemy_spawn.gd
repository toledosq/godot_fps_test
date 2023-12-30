class_name EnemySpawn extends Marker3D

signal enemy_spawned()

@export var enemy_scene: PackedScene


func _ready():
	EventBus.spawn_enemy.connect(spawn_enemy)


func spawn_enemy():
	var new_enemy: CharacterBody3D = enemy_scene.instantiate()
	add_child(new_enemy)
	new_enemy.global_transform.origin += Vector3(randf_range(-2.0, 2.0), 0, randf_range(-2.0, 2.0))
	EventBus.enemy_spawned.emit()
