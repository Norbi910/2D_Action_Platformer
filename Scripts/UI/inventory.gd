extends Resource
class_name PlayerData

@export var items: Array[InventoryItem]
@export var completed_quests: Array[StringName]

func reset():
	items.clear()
	completed_quests.clear()

func hasItem(name: StringName) -> bool:
	for item in items:
		if item.name == name:
			return true
	return false

func removeItem(name: StringName):
	var chosen
	for item in items:
		if item.name == name:
			chosen = item
			break
	if chosen:
		items.erase(chosen)
		emit_changed()
	
