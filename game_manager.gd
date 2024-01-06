class_name GameManager extends Node

const pick_up = preload("res://items/pickups/pickup.tscn")

@export var level_override: PackedScene

@onready var inventory_interface = $UI/InventoryInterface
#@onready var hot_bar_inventory = $UI/HotBarInventory

var current_level: Level
var player


func _ready():
	load_level()
	player = Globals.current_player
	initialize_inventories()
	EventBus.player_died.connect(on_player_death)


func load_level():
	if level_override.can_instantiate():
		var level = level_override.instantiate()
		add_child(level)
		current_level = level
		Globals.current_level = level
		print("%s loaded" % current_level.name)


func on_player_death():
	print("You died")
	current_level.queue_free()
	load_level()


func initialize_inventories() -> void:
	# Connect player to inventory interface
	player.toggle_inventory.connect(toggle_inventory_interface)
	
	# Populate player inventory
	inventory_interface.set_player_inventory_data(player.inventory_data)
	
	# Populate armor inventory
	# inventory_interface.set_armor_inventory_data(player.armor_inventory_data)
	
	# Populate weapon inventory
	# inventory_interface.set_weapon_inventory_data(player.weapon_inventory_data)
	
	# Connect to the interface's force_close signal
	inventory_interface.force_close.connect(toggle_inventory_interface)
	
	# Connect to interface's drop item in world signal
	inventory_interface.drop_slot_data.connect(_on_inventory_interface_drop_slot_data)
	
	# Populate hotbar with player inventory data
	# hot_bar_inventory.set_inventory_data(player.inventory_data)
	
	# Find all containers in world and connect to their toggle function (for interacting)
	for node in get_tree().get_nodes_in_group("external_inventory"):
		node.toggle_inventory.connect(toggle_inventory_interface)


func toggle_inventory_interface(container = null) -> void:
# Inventory interface is hidden by default
	inventory_interface.visible = not inventory_interface.visible
	
	# Show mouse if interface is visible
	if inventory_interface.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		#hot_bar_inventory.hide()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		#hot_bar_inventory.show()

	# If an external inventory is being interacted with, populate the container panel
	if container and inventory_interface.visible:
		inventory_interface.set_container_inventory(container)
	else:
		inventory_interface.clear_container_inventory()


func _on_inventory_interface_drop_slot_data(slot_data):
	var pick_up_ = pick_up.instantiate()
	pick_up_.slot_data = slot_data
	pick_up_.position = player.get_drop_position()
	current_level.add_child(pick_up_)
