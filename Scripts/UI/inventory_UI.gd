extends Control

@onready var inventory: PlayerData = preload("res://Resources/Inventory/player_inventory.tres")
@onready var slots: Array = $ColorRect/GridContainer.get_children()

func _ready() -> void:
	visible = false
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("open_inventory"):
		visible = not visible
		update_slots()
	if inventory.changed:
		update_slots()

func update_slots():
	for i in range(inventory.items.size()):
		slots[i].update(inventory.items[i])
	for i in range(inventory.items.size(), slots.size() - inventory.items.size()):
		slots[i].update(null)
	
