extends Sprite2D
class_name Customer 

signal on_stand
signal finished
var res:Cus_Res
var item:Item_Base
var spawn:Marker2D
var stand:Marker2D
var bubub:TextureRect
var price_node:Label

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
	var bubble = TextureRect.new()
	bubble.texture = load("res://Asset/Ellipse 10.png") 
	bubble.position = Vector2(171.25,-202.5)
	self.add_child(bubble)
	var item_node = TextureRect.new()
	if item.unlocked:
		item_node.texture = item.sprite
	else:
		item_node.texture = item.mysprite
	var CC = CenterContainer.new()
	CC.anchor_right = 1
	CC.anchor_bottom = 1
	bubble.add_child(CC)
	CC.add_child(item_node)
	bubub = bubble
	var price:Label = Label.new()
	var font = price.get_theme_font("font")
	var font_size = 40
	price.add_theme_font_size_override("font_size", font_size)
	price.position = Vector2(178.75, 5.0)
	price.size = Vector2(158.0, 55.0) 
	price.rotation_degrees = 40.0
	bubble.add_child(price)
	price_node = price
	get_tree().current_scene.cur_cus = self
	

func set_price(v:int):
	price_node.text = str(v)
	

func get_the_hell_out():
	bubub.visible = false
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
