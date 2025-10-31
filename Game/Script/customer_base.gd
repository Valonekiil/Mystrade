extends Sprite2D
class_name Customer 

signal on_stand
signal finished
var res:Cus_Res
var item:Item_Base
var spawn:Marker2D
var stand:Marker2D

func _ready() -> void:
	var twin:Tween = create_tween()
	twin.tween_property(self,"global_position", stand.global_position, 1)
	twin.set_ease(Tween.EASE_OUT)
	twin.set_trans(Tween.TRANS_BACK)
	twin.finished.connect(on_stand_point)

func on_stand_point():
	#var tween = create_tween()
	#tween.tween_property(self, "self_modulate", Color(1.5, 1.5, 1.0), 0.2)
	#tween.tween_property(self, "self_modulate", Color.WHITE, 1)
	#tween.set_loops()
	on_stand.emit()
	var outline = Sprite2D.new()
	outline.texture = load("res://icon.svg")
	outline.modulate = Color(0, 0, 0)  # Cyan outline
	outline.show_behind_parent = true
	outline.scale = self.scale * 1.1
	self.add_child(outline)
	var item_node = TextureRect.new()
	if item.unlocked:
		item_node.texture = item.sprite
	else:
		item_node.texture = item.mysprite
	get_tree().current_scene.cur_cus = self

func show_item():
	var item = TextureRect.new()
	

func get_the_hell_out():
	var twin:Tween = create_tween()
	twin.tween_property(self,"global_position", spawn.global_position, 1)
	twin.set_ease(Tween.EASE_OUT)
	twin.set_trans(Tween.TRANS_BACK)
	await  twin.finished
	finished.emit()
	queue_free()
	get_tree().current_scene.cur_cus = null
	if get_tree().current_scene.cur_cus:
		print("lah kok onok")
