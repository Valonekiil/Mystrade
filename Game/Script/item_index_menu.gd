extends ColorRect

@onready var Slot:PackedScene = load("res://Scene/Item_Slot.tscn")
@onready var Slot_Con:GridContainer = $GridContainer
@onready var Item_Img = $Panel/TextureRect
@onready var Item_Name = $Panel/Label1
@onready var Item_Desc = $Panel/Label2
@onready var Item_Worth = $Panel/HBoxContainer/Label

func _ready() -> void:
	GameDataManager.show_item.connect(show_item)
	visibility_changed.connect(_on_visibility_changed)

func show_unlocked_item():
	for v in Slot_Con.get_children():
		v.queue_free()
	
	var items = GameDataManager.get_unlocked_items()
	for item in items:
		var display:Item_Slot = Slot.instantiate()
		display.item = item
		Slot_Con.add_child(display)
		display.sprite.texture = item.sprite

func _on_visibility_changed():
	if visible:
		await get_tree().process_frame
		show_unlocked_item()
		await get_tree().process_frame
		if Slot_Con.get_child_count() > 0:
			Slot_Con.get_child(0).grab_focus.call_deferred()
			print("haruse wes fokus")
	else :
		if get_viewport().gui_get_focus_owner():
			get_viewport().gui_get_focus_owner().release_focus()
			print("lose focus")

func show_item(item:Item_Base):
	Item_Name.text = item.name
	Item_Desc.text = item.desc
	Item_Worth.text = str(item.worth)
	Item_Img.texture = item.sprite
