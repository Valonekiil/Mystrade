extends Node2D

@onready var Spawn = $Spawn
@onready var Stand = $Stand
var cur_cus:Customer

func _ready() -> void:
	#GameDataManager.player_data_updated.connect(update_ui)
	spawn_costumer()
	

func _on_timer_timeout() -> void:
	if cur_cus == null:
		spawn_costumer()

func spawn_costumer():
	var customer = Customer.new()
	var cus_res:Cus_Res = StateManager.customers.pick_random()
	customer.scale = Vector2(0.8, 0.8)
	customer.res = cus_res
	customer.texture = cus_res.sprite
	customer.spawn = Spawn
	customer.stand = Stand
	customer.global_position = Spawn.global_position
	customer.item = StateManager.items.pick_random()
	self.add_child(customer)

func buy_item():
	pass
