extends Control

@onready var message_label = $MessageLabel
@onready var login_page: Control = $LoginPage
@onready var local_page: Control = $LocalPage
@onready var leader_board: Control = $LeaderBoard
@onready var anim: AnimationPlayer = $Anim
@onready var cloud_btn: Button = $Cloud_Btn
@onready var local_btn: Button = $Local_Btn
@onready var play_btn: Button = $Play_Btn
@onready var bg: TextureRect = $TakBerjudul11820251105145740

var not_skip:bool
var state:int = 0
var current_player_id: int = -1

func _ready():
	SceneTransition.play("fade_out")
	cloud_btn.visible = false
	play_btn.visible = false
	local_btn.visible = false
	bg.visible = false
	leader_board.visible = false
	anim.play("Hide_LB", -1 , 100)
	await anim.animation_finished
	anim.play("Hide_Login", -1 , 100)
	await anim.animation_finished
	anim.play("Hide_Local", -1 , 100)
	await SceneTransition.finished
	anim.play("Start")
	state = 0
	print(GameDataManager.current_player)
	if !GameDataManager.current_player.username:
		GameDataManager.current_player = null
		print("player di hapus")

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_SPACE) and anim.is_playing() and !not_skip and anim.current_animation == "Start":
		not_skip = true
		anim.seek(anim.current_animation_length, true)
		await  anim.animation_finished
		not_skip = false

func _on_local_pressed():
	if anim.is_playing():
		return
	if state == 1:
		anim.play("Hide_Local")
		await anim.animation_finished
		state = 0
	elif state == 2:
		anim.play("Hide_Login")
		await anim.animation_finished
		anim.play("Show_Local")
		await anim.animation_finished
		state = 1
	else:
		anim.play("Show_Local")
		await anim.animation_finished
		state = 1

func _on_cloud_pressed():
	if anim.is_playing():
		return
	if state == 2:
		anim.play("Hide_Login")
		await anim.animation_finished
		state = 0
	elif state == 1:
		anim.play("Hide_Local")
		await anim.animation_finished
		anim.play("Show_Login")
		await anim.animation_finished
		state = 2
	else:
		anim.play("Show_Login")
		await anim.animation_finished
		state = 2

func _on_play_offline_pressed():
	if GameDataManager.current_player:
		get_tree().change_scene_to_file("res://main.tscn")
	else:
		show_message("Silahkan buat save dulu!", Color.RED)

func _on_load_leaderboard():
	anim.play("Hide_Login", -1, 0.5)
	await anim.animation_finished
	anim.play("Show_LB")
	leader_board.visible = true
	await anim.animation_finished
	leader_board.load_leaderboard()

func _on_close_leaderboard():
	leader_board.clear_leaderboard()
	anim.play("Hide_LB")
	await anim.animation_finished
	anim.play("Show_Login", -1, 0.5)

func show_message(text: String, color: Color):
	message_label.text = text
	message_label.modulate = color
	message_label.visible = true
	await get_tree().create_timer(3).timeout
	message_label.visible = false
