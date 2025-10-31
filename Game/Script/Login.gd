extends Control

@onready var player_id_input = $PlayerIDInput
@onready var username_input = $UsernameInput
@onready var password_input = $PasswordInput  
@onready var items_input = $ItemsInput
@onready var message_label = $MessageLabel

var current_player_id: int = -1

func _ready():
	HTTPManager.request_completed.connect(_on_registration_completed)
	HTTPManager.get_player_completed.connect(_on_get_player_completed)
	HTTPManager.update_player_completed.connect(_on_update_completed)

func _start_button_pressed():
	var username = username_input.text.strip_edges()
	var password = password_input.text
	
	if username.is_empty() or password.is_empty():
		show_message("Username dan password wajib diisi!", Color.RED)
		return
	GameDataManager.login_and_sync(username, password)
	show_message("Logging in...", Color.YELLOW)

func _on_play_offline_pressed():
	# Main dengan data lokal saja
	get_tree().change_scene_to_file("res://GameScene.tscn")

func _on_register_button_pressed():
	var username = username_input.text.strip_edges()
	var password = password_input.text
	
	# Validation
	if username.is_empty() or password.is_empty():
		show_message("Username dan password wajib diisi!", Color.RED)
		return
	
	show_message("Mendaftarkan...", Color.YELLOW)
	HTTPManager.register_player(username, password)

func _on_registration_completed(player_data, error_message):
	if error_message:
		show_message("Error: " + error_message, Color.RED)
	else:
		show_message("Registrasi berhasil! ID: " + str(player_data["id"]), Color.GREEN)
		# Clear inputs
		username_input.text = ""
		password_input.text = ""

func _on_get_player_button_pressed():
	var player_id = player_id_input.text.to_int()
	if player_id > 0:
		HTTPManager.get_player_by_id(player_id)
		show_message("Mengambil data...", Color.YELLOW)
	else:
		show_message("ID tidak valid!", Color.RED)

func _on_get_player_completed(player_data, error_message):
	if error_message:
		show_message("Error: " + error_message, Color.RED)
	elif player_data:
		current_player_id = player_data["id"]
		username_input.text = player_data["username"]
		password_input.text = player_data["password"] 
		items_input.text = str(player_data["item"])
		show_message("Data loaded!", Color.GREEN)

func _on_update_button_pressed():
	if current_player_id == -1:
		show_message("Load player data dulu sayang!", Color.RED)
		return
	
	var username = username_input.text
	var password = password_input.text
	var items = items_input.text.to_int()
	
	HTTPManager.update_player(current_player_id, username, password, items)
	show_message("Updating...", Color.YELLOW)

func _on_update_completed(updated_player, error_message):
	if error_message:
		show_message("Update gagal: " + error_message, Color.RED)
	else:
		show_message("Update berhasil! Items: " + str(updated_player["item"]), Color.GREEN)

func show_message(text: String, color: Color):
	message_label.text = text
	message_label.modulate = color
