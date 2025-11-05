extends CanvasLayer

@onready var Ask_Btn =$VBoxContainer/Button4
@onready var Acc_Btn =$VBoxContainer/Button
@onready var Egx_Btn =$VBoxContainer/Button2
@onready var Dsc_Btn =$VBoxContainer/Button3
@onready var Dialog = $Dialogue_Manager
@onready var Notif =$Popup
@onready var Notif_Name =$Popup/Pop_up/Name
@onready var Notif_Msg =$Popup/Pop_up/Label
@onready var Notif_Sprite =$Popup/Pop_up/Sprite
@onready var Notif_Worth =$Popup/Pop_up/HBoxContainer/Worth
@onready var Kamus = $Item_Index
@onready var qte = $QTE
@onready var Pause_Menu = $ColorRect
@export var Mad:CompressedTexture2D
@export var Happy:CompressedTexture2D
var Price:int
var main

func _ready() -> void:
	main = get_tree().current_scene
	Kamus.visible = false
	Ask_Btn.disabled = true
	Acc_Btn.disabled = true
	Egx_Btn.disabled = true
	Dsc_Btn.disabled = true
	Dialog.finished.connect(_finish_ask)
	qte.discount.connect(after_bargain)
	Pause_Menu.visible = false

func _customer_appear():
	Ask_Btn.disabled = false
	Ask_Btn.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	
	if Input.is_key_pressed(KEY_TAB):
		Kamus.visible = !Kamus.visible

func show_kamus()-> void:
	Kamus.visible = true

func hide_kamus() -> void:
	Kamus.visible = true

func _on_ask() -> void:
	Dialog.conversations = main.cur_cus.item.dialogue
	print(Dialog.conversations)
	Dialog.talking()
	Ask_Btn.disabled = true
	print($Dialogue_Manager/Panel.visible)

func _finish_ask()-> void:
	Price = main.cur_cus.item.worth
	main.cur_cus.set_price(Price)
	Acc_Btn.disabled = false
	Egx_Btn.disabled = false
	Dsc_Btn.disabled = false
	Acc_Btn.grab_focus()

func _on_cus_leave():
	Acc_Btn.disabled = true
	Egx_Btn.disabled = true
	Dsc_Btn.disabled = true

func _on_bought()-> void:
	if GameDataManager.current_player.coins <= Price:
		_on_decline()
		return
	GameDataManager.spend_coins(Price)
	var item = main.cur_cus.item
	if item.unlocked:
		pop_up_push(item,"Selamat!\n kamu membeli")
	else:
		GameDataManager.unlock_item(item.name)
		GameDataManager.unlock_player_item(item)
		pop_up_push(item,"Selamat\n kamu menemukan")
	GameDataManager.add_coins(item.worth)
	main.cur_cus.sprite_bub.texture = Happy
	main.cur_cus.get_the_hell_out()
	_on_cus_leave()

func _on_decline()-> void:
	print("customer pergi dengan kecewa")
	main.cur_cus.sprite_bub.texture = Mad
	main.cur_cus.get_the_hell_out()
	_on_cus_leave()

func _on_bargain()-> void:
	Acc_Btn.disabled = true
	Egx_Btn.disabled = true
	Dsc_Btn.disabled = true
	qte.Start_Qte()

func after_bargain(v:int):
	print("Harga lama: ", Price)
	var original_price = Price
	var discount_amount = original_price * (float(v) / 100.0)
	Price = original_price - discount_amount
	print("Discount: ", v, "% - Harga baru: ", Price)
	Acc_Btn.disabled = false
	Egx_Btn.disabled = false
	main.cur_cus.set_price(Price)

func pop_up_push(item:Item_Base, msg:String):
	Notif_Msg.text = msg
	Notif_Name.text = item.name
	Notif_Sprite.texture = item.sprite
	Notif_Worth.text = str(item.worth)
	Notif.popup()
	await get_tree().create_timer(5).timeout
	if Notif.visible == true:
		Notif.hide()
		print("sembunyi paksa")

func _paused()-> void:
	get_tree().paused = true
	Pause_Menu.visible = true
	$ColorRect/VBoxContainer/Button.grab_focus()

func _resume()-> void:
	get_tree().paused = false
	Pause_Menu.visible = false
	Acc_Btn.grab_focus()

func _quit()-> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scene/Login.tscn")
