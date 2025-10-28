extends Resource
class_name Item_Base

@export var name:String
@export_range(1, 10, 1) var scaling:int
@export var sprite:CompressedTexture2D
@export var worth:int
@export_multiline var desc:String
@export var dialogue:Array[Convo_Res]
var unlocked:bool
