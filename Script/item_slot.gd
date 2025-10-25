extends Button
class_name Item_Slot

@onready var darker = $Panel
@onready var sprite:TextureRect = $TextureRect
var item:Item_Base

func _ready() -> void:
	if item:
		sprite.texture = item.sprite

func _on_focus_entered() -> void:
	darker.visible = false
	StateManager.show_item.emit(item)
	print("sekarang focus ke " + item.name )

func _on_focus_exited() -> void:
	darker.visible = true
	print("sekarang focus keluar dari " + item.name )
