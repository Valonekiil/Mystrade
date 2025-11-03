# GameDataManager.gd (Autoload)
extends Node

# Signals
signal player_data_loaded()
signal player_data_updated()
signal sync_completed()
signal auto_save_triggered()
signal show_item(item: Item_Base)

# Player Data
var current_player: PlayerData
var is_online: bool = false
var is_playing: bool = false

# Game Content Data
@export var all_items: Array[Item_Base] = []          # Semua item yang ada di game
@export var all_customers: Array[Cus_Res] = []        # Semua customer resource
var unlocked_items: Array[Item_Base] = []             # Item yang sudah di-unlock player

# Timers
var play_timer: Timer
var auto_save_timer: Timer

func _ready():
	load_local_player_data()
	setup_timers()
	load_game_content()
	
	# Connect HTTPManager signals
	HTTPManager.login_success.connect(_on_login_success)
	HTTPManager.login_failed.connect(_on_login_failed)
	HTTPManager.update_player_completed.connect(_on_update_completed)
	
	# Handle game closure
	get_tree().root.get_window().close_requested.connect(_on_window_close_requested)

func setup_timers():
	# Timer untuk time_played (setiap detik)
	play_timer = Timer.new()
	play_timer.wait_time = 1.0
	play_timer.timeout.connect(_on_play_timer_timeout)
	add_child(play_timer)
	
	# Timer untuk auto-save (setiap 30 detik)
	auto_save_timer = Timer.new()
	auto_save_timer.wait_time = 30.0
	auto_save_timer.timeout.connect(_on_auto_save_timeout)
	add_child(auto_save_timer)

# ==================== GAME CONTENT MANAGEMENT ====================
func load_game_content():
	# Load semua items dan customers yang sudah di-export di inspector
	# Atau bisa juga load dari folder resources
	pass

func register_item(item: Item_Base):
	if not all_items.has(item):
		all_items.append(item)

func register_customer(customer: Cus_Res):
	if not all_customers.has(customer):
		all_customers.append(customer)

func unlock_item(item_name: String):
	for item in all_items:
		if item.name == item_name:
			item.unlocked = true
			if not unlocked_items.has(item):
				unlocked_items.append(item)
			show_item.emit(item)
			break

func get_unlocked_items() -> Array[Item_Base]:
	return unlocked_items.duplicate()

func get_locked_items() -> Array[Item_Base]:
	var locked = []
	for item in all_items:
		if not item.unlocked:
			locked.append(item)
	return locked

func get_random_customer() -> Cus_Res:
	if all_customers.size() > 0:
		return all_customers.pick_random()
	return null

func get_random_item() -> Item_Base:
	if all_items.size() > 0:
		return all_items.pick_random()
	return null

# ==================== PLAYER SESSION MANAGEMENT ====================
func _on_play_timer_timeout():
	if is_playing and current_player:
		current_player.time_played += 1
		player_data_updated.emit()

func _on_auto_save_timeout():
	if is_playing and current_player:
		save_local_player_data()
		sync_to_server()
		auto_save_triggered.emit()

func login_and_sync(username: String, password: String):
	HTTPManager.login_player(username, password)

func _on_login_success(api_data: Dictionary):
	if api_data.is_empty():
		print("Error: API data kosong!")
		return
	
	# PAKE .get() DENGAN DEFAULT VALUE
	current_player.update_from_api(api_data)
	start_playing()
	player_data_loaded.emit()
	print("Login berhasil! Selamat datang ", current_player.username)

func _on_login_failed(error_message):
	print("Login gagal: ", error_message)

func start_playing():
	if current_player:
		is_playing = true
		play_timer.start()
		auto_save_timer.start()
		save_local_player_data()
		HTTPManager.start_game_session(current_player.player_id)

func stop_playing():
	if current_player:
		is_playing = false
		play_timer.stop()
		auto_save_timer.stop()
		save_local_player_data()
		HTTPManager.end_game_session(current_player.player_id)

# ==================== PLAYER DATA MANAGEMENT ====================
func add_coins(amount: int):
	if current_player:
		current_player.coins += amount
		player_data_updated.emit()
		save_local_player_data()
		HTTPManager.update_player_coins(current_player.player_id, current_player.coins)

func spend_coins(amount: int) -> bool:
	if current_player and current_player.coins >= amount:
		current_player.coins -= amount
		player_data_updated.emit()
		save_local_player_data()
		HTTPManager.update_player_coins(current_player.player_id, current_player.coins)
		return true
	return false

func unlock_player_item(item: Item_Base):
	if current_player and not current_player.has_item(item.id):
		current_player.add_to_collection(item.id)
		player_data_updated.emit()
		save_local_player_data()
		HTTPManager.add_item_to_collection(current_player.player_id, item.id)
		print("Item unlocked in collection: ", item.name)

func get_player_unlocked_items() -> Array[Item_Base]:
	var unlocked: Array[Item_Base] = []
	if current_player:
		for item_id in current_player.item_collection:
			var item = get_item_by_id(item_id)
			if item:
				unlocked.append(item)
	return unlocked

func get_item_by_id(item_id: int) -> Item_Base:
	for item in all_items:
		if item.id == item_id:
			return item
	return null

# ==================== SAVE/LOAD SYSTEM ====================
func save_local_player_data():
	if current_player:
		ResourceSaver.save(current_player, "user://player_data.tres")

func load_local_player_data():
	if FileAccess.file_exists("user://player_data.tres"):
		current_player = load("user://player_data.tres")
		# Sync unlocked_items dengan player data
		sync_unlocked_items_with_player_data()
	else:
		current_player = PlayerData.new()
		current_player.player_id = -1

func sync_unlocked_items_with_player_data():
	unlocked_items.clear()
	if current_player:
		for item_id in current_player.item_collection:
			var item = get_item_by_id(item_id)
			if item:
				item.unlocked = true
				unlocked_items.append(item)

func sync_to_server():
	if current_player.player_id != -1:
		var update_data = {
			"username": current_player.username,
			"password": current_player.password,
			"coins": current_player.coins,
			"timePlayed": current_player.time_played,
			"itemCollection": current_player.item_collection
		}
		HTTPManager.update_player(current_player.player_id, update_data)

func _on_update_completed(updated_player, error_message):
	if error_message:
		print("Sync gagal: ", error_message)
	else:
		print("Sync berhasil!")
		sync_completed.emit()

# ==================== SYSTEM EVENT HANDLERS ====================
func _on_window_close_requested():
	stop_playing()
	get_tree().quit()

func _notification(what):
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			stop_playing()
		NOTIFICATION_CRASH:
			stop_playing()
