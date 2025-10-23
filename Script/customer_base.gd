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
	print("aku siap")
	await get_tree().create_timer(2).timeout
	var twin:Tween = create_tween()
	twin.tween_property(self,"global_position", spawn.global_position, 1)
	twin.set_ease(Tween.EASE_OUT)
	twin.set_trans(Tween.TRANS_BACK)
