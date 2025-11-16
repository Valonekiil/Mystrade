extends Panel
class_name SaveSlot

signal slot_selected(slot_number: int, player_data: PlayerData)
signal slot_deleted(slot_number: int, player_data: PlayerData)

var Data: PlayerData
var slot_number: int

@onready var Number: Label = $HBoxContainer/Label
@onready var Username: Label = $HBoxContainer/VBoxContainer/Label
@onready var Playtime: Label = $HBoxContainer/VBoxContainer/Label2
@onready var Coin: Label = $HBoxContainer/VBoxContainer2/Label
@onready var Items: Label = $HBoxContainer/VBoxContainer2/Label2
@onready var Status: Label = $HBoxContainer/VBoxContainer/StatusLabel
@onready var Btn: Button = $HBoxContainer/Button

func _ready():
	Btn.pressed.connect(_slot_deleted)
	gui_input.connect(_on_slot_gui_input)

func init(no: int):
	slot_number = no
	Number.text = str(no)
	clear_slot()

func clear_slot():
	Data = null
	Username.text = "Empty Slot"
	Playtime.text = "No Data"
	Coin.text = "Coin: 0"
	Items.text = "Items: 0"
	Btn.visible = false
	if Status:
		Status.text = ""

func update_save(data: PlayerData):
	Data = data
	Username.text = data.username
	print("update data ", data.username, " dengan ", data.time_played )
	# Format waktu yang cantik
	Playtime.text = format_play_time(data.time_played)
	
	Coin.text = "Coin: " + str(data.coins)
	Items.text = "Items: " + str(data.item_collection.size())
	Btn.visible = true
	if Status:
		if data.player_id == -1:
			Status.text = "🔴 Offline"
			Status.modulate = Color.RED
		else:
			Status.text = "🟢 Online"
			Status.modulate = Color.GREEN

func format_play_time(seconds: int) -> String:
	var days = seconds / (24 * 3600)
	seconds = seconds % (24 * 3600)
	var hours = seconds / 3600
	seconds %= 3600
	var minutes = seconds / 60
	seconds %= 60
	
	var time_parts = []
	if days > 0:
		time_parts.append(str(days) + "D")
	if hours > 0:
		time_parts.append(str(hours) + "H")
	if minutes > 0:
		time_parts.append(str(minutes) + "M")
	if seconds > 0 or time_parts.is_empty():
		time_parts.append(str(seconds) + "S")
	
	return " ".join(time_parts)

func _on_slot_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if Data != null:
			# Slot ada data - emit signal untuk load
			slot_selected.emit(slot_number, Data)
		else:
			# Slot kosong - emit signal untuk create new
			slot_selected.emit(slot_number, null)
		
		# Visual feedback
		modulate = Color.GRAY
		await get_tree().create_timer(0.1).timeout
		modulate = Color.WHITE

func _slot_deleted():
	if !Data:
		return
	slot_deleted.emit(slot_number, Data)
