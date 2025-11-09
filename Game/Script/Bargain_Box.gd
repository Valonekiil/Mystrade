extends Control

signal discount(v:int)
@onready var bg: Sprite2D = $BG
@onready var pointer: Sprite2D = $CRSR
@onready var start_point: Marker2D = $StartPoint
@onready var average_start: Marker2D = $AverageStart
@onready var succes_start: Marker2D = $SuccesStart
@onready var succes_end: Marker2D = $SuccesEnd
@onready var average_end: Marker2D = $AverageEnd
@onready var end_point: Marker2D = $EndPoint

var speed = 500
var direction = 1

func _ready() -> void:
	End_Qte()

func _physics_process(delta: float) -> void:
	if pointer.position.y <= start_point.position.y:
		direction = 1
	elif pointer.position.y >= end_point.position.y:
		direction = -1
	
	pointer.position.y += direction * speed * delta
	
	if Input.is_key_pressed(KEY_V):
		if pointer.position.y >= succes_start.position.y and pointer.position.y <= succes_end.position.y:
			print("Critical")
			var v = randi_range(25, 50)
			emit_signal("discount", v)
			End_Qte()
			return
		elif pointer.position.y >= average_start.position.y and pointer.position.y <= average_end.position.y:
			var v = randi_range(10, 25)
			emit_signal("discount", v)
			print("Sukses")
			End_Qte()
			return
		elif  pointer.position.y >= start_point.position.y and pointer.position.y <= end_point.position.y:
			var v = randi_range(-30, 10)
			emit_signal("discount", v)
			print("Gagal")
			End_Qte()
			return

func Start_Qte():
	self.visible = true
	self.set_physics_process(true)
	

func End_Qte():
	self.set_physics_process(false)
	self.visible = false
