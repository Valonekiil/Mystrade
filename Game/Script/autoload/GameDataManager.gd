extends Node

signal player_data_loaded()
signal player_data_updated()
signal sync_completed()

var current_player: PlayerData
var is_online: bool = false

func _ready():
	load_local_player_data()
	# Connect HTTPManager signals
	HTTPManager.login_success.connect(_on_login_success)
	HTTPManager.login_failed.connect(_on_login_failed)
	HTTPManager.update_player_completed.connect(_on_update_completed)

func _on_login_failed(error_message):
	print("Login failed: ", error_message)

# Login dan load data dari API
func login_and_sync(username: String, password: String):
	HTTPManager.login_player(username, password)

func _on_login_success(api_data: Dictionary):
	# Update player data dari API
	current_player.update_from_api(api_data)
	save_local_player_data()
	player_data_loaded.emit()
	print("Player data synced from API!")

# Simpan data lokal
func save_local_player_data():
	if current_player:
		ResourceSaver.save(current_player, "user://player_data.tres")

# Load data lokal
func load_local_player_data():
	if FileAccess.file_exists("user://player_data.tres"):
		current_player = load("user://player_data.tres")
	else:
		# Buat data baru kalo belum ada
		current_player = PlayerData.new()
		current_player.player_id = -1  # Belum login

# Update data di game (local)
func add_items(count: int):
	if current_player:
		current_player.items += count
		player_data_updated.emit()
		save_local_player_data()

func add_experience(exp: int):
	if current_player:
		current_player.experience += exp
		# Level up logic
		while current_player.experience >= get_exp_for_level(current_player.level):
			current_player.experience -= get_exp_for_level(current_player.level)
			current_player.level += 1
		player_data_updated.emit()
		save_local_player_data()

func get_exp_for_level(level: int) -> int:
	return level * 100  # Contoh formula

# Sync ke server
func sync_to_server():
	if current_player.player_id != -1:  # Pastikan sudah login
		HTTPManager.update_player(
			current_player.player_id,
			current_player.username,
			current_player.password,
			current_player.items
		)

func _on_update_completed(updated_player, error_message):
	if error_message:
		print("Sync failed: ", error_message)
	else:
		print("Sync successful!")
		sync_completed.emit()
