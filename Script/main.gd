extends Node2D

@onready var Spawn = $Spawn
@onready var Stand = $Stand

func _ready() -> void:
	var customer = Customer.new()
	customer.texture = load("res://icon.svg")
	customer.spawn = Spawn
	customer.stand = Stand
	customer.global_position = Spawn.global_position
	self.add_child(customer)
