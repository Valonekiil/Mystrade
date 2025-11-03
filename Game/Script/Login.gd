extends Control

@onready var player_id_input = $PlayerIDInput
@onready var username_input = $UsernameInput
@onready var password_input = $PasswordInput  
@onready var items_input = $ItemsInput
@onready var message_label = $MessageLabel
@onready var LoginBTn = $Button1
@onready var LogoutBTn = $Button3
@onready var StartBTn = $Button2

var current_player_id: int = -1

func _ready():
	HTTPManager.login_failed.connect(on_login_failed)
	HTTPManager.login_success.connect(on_login_succes)
	LogoutBTn.disabled = true
	pass

func _login_button_pressed():
	var username = username_input.text.strip_edges()
	var password = password_input.text
	
	if username.is_empty() or password.is_empty():
		show_message("Username dan password wajib diisi!", Color.RED)
		return
	GameDataManager.login_and_sync(username, password)
	show_message("Logging in...", Color.YELLOW)

func on_login_succes(api_data:Dictionary):
	var username:String 
	username = api_data.get("username", username)
	show_message("Selamat datang " + username, Color.GREEN)
	LogoutBTn.disabled = false
	LoginBTn.disabled = true

func on_login_failed(pesan):
	show_message(pesan,Color.RED)

func _logout_button_pressed():
	GameDataManager.current_player = null
	show_message("Logging out...", Color.YELLOW)
	LogoutBTn.disabled = true
	LoginBTn.disabled = false

func _on_play_offline_pressed():
	# Main dengan data lokal saja
	get_tree().change_scene_to_file("res://main.tscn")

func show_message(text: String, color: Color):
	message_label.text = text
	message_label.modulate = color
