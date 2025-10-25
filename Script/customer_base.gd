extends Sprite2D
class_name Customer 

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
	var outline = Sprite2D.new()
	outline.texture = load("res://icon.svg")
	outline.modulate = Color(0, 0, 0)  # Cyan outline
	outline.show_behind_parent = true
	outline.scale = self.scale * 1.1
	self.add_child(outline)
	get_tree().current_scene.cur_cus = self
	print(get_tree().current_scene.cur_cus)

func show_item():
	var item = TextureRect.new()
	

func get_the_hell_out():
	var twin:Tween = create_tween()
	twin.tween_property(self,"global_position", spawn.global_position, 1)
	twin.set_ease(Tween.EASE_OUT)
	twin.set_trans(Tween.TRANS_BACK)
	await  twin.finished
	queue_free()
	get_tree().current_scene.cur_cus = null
	if get_tree().current_scene.cur_cus:
		print("lah kok onok")
