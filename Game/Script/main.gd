extends Node2D

@onready var Spawn = $Spawn
@onready var Stand = $Stand
@onready var Spawner = $Timer
@onready var Gold_Lbl = $CanvasLayer/Gold_PH
@onready var UI = $CanvasLayer
var cur_cus:Customer

func _ready() -> void:
	if GameDataManager.current_player:
		print("Halo pemain " + GameDataManager.current_player.username)
		update_ui()
	GameDataManager.player_data_updated.connect(update_ui)
	if GameDataManager.current_player.last_customer and GameDataManager.current_player.last_item:
		spawn_costumer(GameDataManager.current_player.last_customer,GameDataManager.current_player.last_item)
		print("Load customer terakhir")
	else:
		spawn_costumer(null,null)
		print("gacha customer")
	if GameDataManager.current_player:
		GameDataManager.start_playing()

func _on_timer_timeout() -> void:
	if cur_cus == null:
		spawn_costumer(null,null)
		print("customer spawn")
	else :
		Spawner.start(randf_range(5,15))
		print("masih ada customer, akan di time lagi")

func spawn_costumer(id_Cus:Variant, item_id:Variant):
	var customer = Customer.new()
	var cus_res:Cus_Res
	if id_Cus:
		var temp
		for res in GameDataManager.all_customers:
			if res.id == id_Cus:
				temp = res
		cus_res = temp
	else:
		cus_res = GameDataManager.all_customers.pick_random()
	customer.scale = Vector2(0.8, 0.8)
	customer.res = cus_res
	customer.texture = cus_res.sprite
	customer.spawn = Spawn
	customer.stand = Stand
	customer.global_position = Spawn.global_position
	if item_id:
		var temp
		for res in GameDataManager.all_items:
			if res.id == item_id:
				temp = res
		customer.item = temp
	else:
		customer.item = cus_res.item_pool.pick_random()
	self.add_child(customer)
	customer.on_stand.connect(UI._customer_appear)
	customer.finished.connect(customer_cleared)

func customer_cleared():
	Spawner.start(randf_range(1,5))
	print("customer pergi")

func update_ui():
	var data:PlayerData = GameDataManager.current_player
	Gold_Lbl.text = "Gold: " + str(data.coins)

func buy_item():
	pass
