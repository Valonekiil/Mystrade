extends Control

@onready var bg: Sprite2D = $BG
@onready var pointer: Sprite2D = $CRSR
@onready var start_point: Marker2D = $StartPoint
@onready var average_start: Marker2D = $AverageStart
@onready var succes_start: Marker2D = $SuccesStart
@onready var succes_end: Marker2D = $SuccesEnd
@onready var average_end: Marker2D = $AverageEnd
@onready var end_point: Marker2D = $EndPoint

var direction = 1

func _physics_process(delta: float) -> void:
	if pointer.position.y <= start_point.position.y:
		direction = 1
	elif pointer.position.y >= end_point.position.y:
		direction = -1
	
	pointer.position.y += direction
	
	if Input.is_key_pressed(KEY_V):
		if pointer.position.y >= succes_start.position.y and pointer.position.y <= succes_end.position.y:
			print("Critical")
			return
		elif pointer.position.y >= average_start.position.y and pointer.position.y <= average_end.position.y:
			print("Sukse")
			return
		elif  pointer.position.y >= start_point.position.y and pointer.position.y <= end_point.position.y:
			print("Gagal")
