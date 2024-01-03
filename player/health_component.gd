class_name HealthComponent extends Node

var MAX_HEALTH : int = 100
var health : int = 100


func on_hit(damage):
	health -= damage
	if health <= 0:
		on_death()


func on_death():
	var parent = get_parent()
	if parent.has_method("on_death"):
		parent.on_death()
	else:
		print("%s died" % parent)
