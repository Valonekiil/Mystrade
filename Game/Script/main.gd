extends Node2D

@onready var Spawn = $Spawn
@onready var Stand = $Stand
@onready var Spawner = $Timer
@onready var Gold_Lbl = $CanvasLayer/Gold_PH
@onready var UI = $CanvasLayer
var cur_cus:Customer

func _ready() -> void:
	GameDataManager.player_data_updated.connect(update_ui)
	spawn_costumer()
	

func _on_timer_timeout() -> void:
	if cur_cus == null:
		spawn_costumer()
		print("customer spawn")
	else :
		Spawner.start(randf_range(5,15))
		print("masih ada customer, akan di time lagi")

func spawn_costumer():
	var customer = Customer.new()
	var cus_res:Cus_Res = GameDataManager.all_customers.pick_random()
	customer.scale = Vector2(0.8, 0.8)
	customer.res = cus_res
	customer.texture = cus_res.sprite
	customer.spawn = Spawn
	customer.stand = Stand
	customer.global_position = Spawn.global_position
	customer.item = GameDataManager.all_items.pick_random()
	self.add_child(customer)
	customer.on_stand.connect(UI._customer_appear)
	customer.finished.connect(customer_cleared)

func customer_cleared():
	Spawner.start(randf_range(1,5))
	print("customer pergi")

func update_ui():
	var data:PlayerData = GameDataManager.current_player
	Gold_Lbl.text = "Gold: " + str(data.items)

func buy_item():
	pass
