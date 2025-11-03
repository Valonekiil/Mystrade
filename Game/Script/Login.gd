extends Control

@onready var player_id_input = $PlayerIDInput
@onready var username_input = $UsernameInput
@onready var password_input = $PasswordInput  
@onready var items_input = $ItemsInput
@onready var message_label = $MessageLabel

var current_player_id: int = -1

func _ready():
	
	pass

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

func show_message(text: String, color: Color):
	message_label.text = text
	message_label.modulate = color
