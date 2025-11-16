extends Control

@onready var SSM: SaveSlotManager = $SaveSlotManager
@onready var message_label: Label = $"../MessageLabel"
@onready var new_slot_panel: Panel = $NewSlotPanel
@onready var name_box: LineEdit = $NewSlotPanel/LineEdit
@onready var delete_slot_panel: Panel = $DeleteSlotPanel

var slot_selected:int

func _ready() -> void:
	SSM.new_game_requested.connect(_on_save_slot_manager_new_game_requested)
	new_slot_panel.visible = false
	delete_slot_panel.visible = false

func _on_save_slot_manager_new_game_requested(slot_number: int):
	new_slot_panel.visible = true
	slot_selected = slot_number

func _on_save_slot_manager_slot_loaded(slot_number: int, player_data: PlayerData):
	# Load player data ke GameManager
	if GameDataManager.load_slot_player_data(slot_number):
		GameDataManager.start_playing()
		get_tree().change_scene_to_file("res://game_scene.tscn")

func _on_create_player_dialog_confirmed(slot_number: int, player_name: String):
	# Create new player
	SSM.create_new_game(slot_number,player_name)

func _confirm_pressed():
	var name = name_box.text.strip_edges()
	_on_create_player_dialog_confirmed(slot_selected,name)
	new_slot_panel.visible = false

func _cancel_pressed():
	name_box.text = ""
	slot_selected = 0
	new_slot_panel.visible = false

func show_delete_confirm(slot_number: int, player_data: PlayerData):
	$DeleteSlotPanel/Label.text = "Apakah kamu yakin mau menghapus user %s ?" % player_data.username
	delete_slot_panel.visible = true
	$DeleteSlotPanel/HBoxContainer/Button.pressed.connect(_delete_user.bind(slot_number,player_data))
	$DeleteSlotPanel/HBoxContainer/Button.disabled = true
	await  get_tree().create_timer(3).timeout
	$DeleteSlotPanel/HBoxContainer/Button.disabled = false

func _delete_user(slot_number: int, player_data: PlayerData):
	SSM.delete_player_data(slot_number, player_data)
	delete_slot_panel.visible = false

func _cancel_delete():
	delete_slot_panel.visible = false
