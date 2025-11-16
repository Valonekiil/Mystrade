extends Control
class_name SaveSlotManager

signal slot_loaded(slot_number: int, player_data: PlayerData)
signal new_game_requested(slot_number: int)

@export var save_slot_scene: PackedScene
@export var slot_container: VBoxContainer
var local_page
var current_slots: Array[SaveSlot] = []
var max_slots: int = 3

func _ready():
	local_page = get_parent()
	initialize_slots()

func initialize_slots():
	for child in slot_container.get_children():
		child.queue_free()
	
	current_slots.clear()
	
	for i in range(max_slots):
		var slot_instance = save_slot_scene.instantiate()
		slot_container.add_child(slot_instance)
		
		var slot_number = i + 1
		slot_instance.init(slot_number)
		slot_instance.slot_selected.connect(_on_slot_selected)
		slot_instance.slot_deleted.connect(local_page.show_delete_confirm)
		# Load existing data if any
		load_slot_data(slot_number, slot_instance)
		
		current_slots.append(slot_instance)

func load_slot_data(slot_number: int, slot: SaveSlot):
	var save_path = "user://player_data_slot_%d.tres" % slot_number
	
	if FileAccess.file_exists(save_path):
		var player_data = load(save_path)
		if player_data and player_data is PlayerData:
			slot.update_save(player_data)
			print("📂 Loaded slot %d: %s" % [slot_number, player_data.username])

func _on_slot_selected(slot_number: int, player_data: PlayerData):
	if player_data == null:
		# New game di slot ini
		new_game_requested.emit(slot_number)
		print("🎮 New game requested for slot %d" % slot_number)
	else:
		GameDataManager.load_slot_player_data(slot_number)
		var msg = "Selamat datang " + player_data.username
		get_tree().current_scene.show_message(msg,Color.GREEN)
		# Load existing game
		#slot_loaded.emit(slot_number, player_data)
		#print("🎮 Loading slot %d: %s" % [slot_number, player_data.username])

func create_new_game(slot_number: int, player_name: String):
	var player_data = PlayerData.new()
	player_data.player_id = -1  # Offline mode
	player_data.username = player_name
	player_data.coins = 1000
	player_data.time_played = 0
	player_data.item_collection = []
	player_data.last_customer = 0
	player_data.last_item = 0
	print("membuat data ",player_data.username," pada slot ", str(slot_number - 1) )
	# Save ke slot specific
	save_player_data(slot_number, player_data)
	
	# Update slot display
	if slot_number - 1 < current_slots.size():
		current_slots[slot_number - 1].update_save(player_data)
	
	return player_data

func save_player_data(slot_number: int, player_data: PlayerData):
	var save_path = "user://player_data_slot_%d.tres" % slot_number
	ResourceSaver.save(player_data, save_path)
	print("💾 Saved slot %d: %s" % [slot_number, player_data.username])

func load_player_data(slot_number: int) -> PlayerData:
	var save_path = "user://player_data_slot_%d.tres" % slot_number
	if FileAccess.file_exists(save_path):
		return load(save_path)
	return null

func delete_player_data(slot_number: int, player_data: PlayerData):
	var save_path = "user://player_data_slot_%d.tres" % slot_number
	if FileAccess.file_exists(save_path):
		var dir = DirAccess.open("user://")
		dir.remove("user://player_data_slot_%d.tres" % slot_number)
		print("🗑️ Saved slot %d: %s deleted" % [slot_number, player_data.username])
		initialize_slots()
	if GameDataManager.current_player == player_data:
		GameDataManager.current_player = null
