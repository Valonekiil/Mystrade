extends Node

signal show_item(item:Item_Base)
@export var items:Array[Item_Base]
var unlocked_items: Array[Item_Base] = []

func register_item(item: Item_Base):
	if not items.has(item):
		items.append(item)

func unlock_item(item_name: String):
	for item in items:
		if item.name == item_name:
			item.unlocked = true
			if not unlocked_items.has(item):
				unlocked_items.append(item)
			break

func get_unlocked_items() -> Array[Item_Base]:
	return unlocked_items.duplicate()

func get_locked_items() -> Array[Item_Base]:
	var locked = []
	for item in items:
		if not item.unlocked:
			locked.append(item)
	return locked
