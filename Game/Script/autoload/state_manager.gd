extends Node

var Gold_Lbl:Label 
var Gold:int
signal show_item(item:Item_Base)
@export var items:Array[Item_Base]
@export var customers:Array[Cus_Res]
var unlocked_items: Array[Item_Base] = []


func init(tgt:Label, amount:Variant):
	Gold_Lbl = tgt
	if amount:
		update_gold(amount)
		return
	update_gold(500)

func update_gold(v:int):
	Gold = v
	Gold_Lbl.text = "Gold: " + str(v)

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
