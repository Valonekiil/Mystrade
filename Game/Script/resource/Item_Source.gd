extends Resource
class_name Item_Base

@export var id:int
@export var name:String
@export_range(0, 10, 1) var scaling:int
@export var sprite:CompressedTexture2D
@export var mysprite:CompressedTexture2D
@export var worth:int
@export_multiline var desc:String
@export var dialogue:Array[Convo_Res]
var unlocked:bool

func get_scaled_price() -> int:
	if scaling <= 0:
		return worth  
	var percent_increase = randf_range(0.10, scaling * 0.20)
	var new_price = worth + (worth * percent_increase)
	return int(round(new_price))
