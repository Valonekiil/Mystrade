# LeaderboardUI.gd
extends Control

@onready var main_panel = $MainPanel
@onready var leaderboard_container = $MainPanel/ScrollContainer/LeaderboardContainer
#@onready var refresh_btn = $MainPanel/RefreshBtn
@onready var title_label = $MainPanel/TitleLabel

func _ready():
	HTTPManager.leaderboard_loaded.connect(_on_leaderboard_loaded)
	#refresh_btn.pressed.connect(load_leaderboard)
	
	# Load leaderboard saat scene dimulai
	load_leaderboard()

func load_leaderboard():
	print("🔄 Loading leaderboard...")
	show_loading_state()
	HTTPManager.get_leaderboard()

func _on_leaderboard_loaded(leaderboard_data, error_message):
	if error_message:
		show_error(error_message)
		return
	
	clear_leaderboard()
	display_leaderboard(leaderboard_data)

func display_leaderboard(leaderboard_data: Array):
	print("🎯 Displaying leaderboard with ", leaderboard_data.size(), " players")
	
	for player_data in leaderboard_data:
		var entry = create_leaderboard_entry(player_data)
		leaderboard_container.add_child(entry)

func create_leaderboard_entry(player_data: Dictionary) -> HBoxContainer:
	var entry = HBoxContainer.new()
	entry.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Rank
	var rank_label = Label.new()
	rank_label.text = str(player_data.get("rank", 0))
	rank_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rank_label.add_theme_font_size_override("font_size", 18)
	
	# Username
	var name_label = Label.new()
	name_label.text = str(player_data.get("username", "Unknown"))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Total Items
	var items_label = Label.new()
	items_label.text = str(player_data.get("totalItems", 0))
	items_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Coins
	var coins_label = Label.new()
	coins_label.text = str(player_data.get("coins", 0))
	coins_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Time Played
	var time_label = Label.new()
	time_label.text = str(player_data.get("timePlayed", "00:00:00"))
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Style berdasarkan rank
	style_entry_by_rank(entry, player_data.get("rank", 0))
	
	# Add semua label ke entry
	entry.add_child(rank_label)
	entry.add_child(name_label)
	entry.add_child(items_label)
	entry.add_child(coins_label)
	entry.add_child(time_label)
	
	return entry

func style_entry_by_rank(entry: HBoxContainer, rank: int):
	match rank:
		1:  # Gold
			entry.modulate = Color.GOLD
			for child in entry.get_children():
				if child is Label:
					child.add_theme_color_override("font_color", Color.BLACK)
		2:  # Silver
			entry.modulate = Color.SILVER
		3:  # Bronze
			entry.modulate = Color(0.8, 0.5, 0.2)  # Bronze color

func clear_leaderboard():
	for child in leaderboard_container.get_children():
		child.queue_free()

func show_loading_state():
	clear_leaderboard()
	var loading_label = Label.new()
	loading_label.text = "Loading leaderboard..."
	loading_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	leaderboard_container.add_child(loading_label)

func show_error(error_message: String):
	clear_leaderboard()
	var error_label = Label.new()
	error_label.text = "Error: " + error_message
	error_label.add_theme_color_override("font_color", Color.RED)
	error_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	leaderboard_container.add_child(error_label)

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://MainMenu.tscn")
