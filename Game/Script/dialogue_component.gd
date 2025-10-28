extends Node
class_name Dialogue_Component

@export var conversations: Array[Convo_Res] = []
#@onready var Trigger = $Trigger
var player_in_area: bool = false  # Apakah pemain berada di area
var player: Node = null  # Referensi ke pemain
var cur_conv:int = 0 

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))


func _on_body_entered(body: Node):
	# Cek apakah objek yang masuk adalah pemain
	if body.has_method("Talking") && cur_conv < conversations.size() :  # Misalnya, pemain memiliki metode "talking"
		player_in_area = true
		player = body

func _on_body_exited(body: Node):
	# Cek apakah objek yang keluar adalah pemain
	if body == player:
		player_in_area = false
		player = null

func _process(delta):
	# Cek jika pemain berada di area dan menekan tombol "Talk"
	#if player_in_area && Input.is_action_just_pressed("Talk") && !GlobalSignal.ui_show:
		#player.Talking(talking())  # Panggil fungsi Talking dengan parameter dari pemain
	pass

func talking():
	for conversation in conversations:
		if conversation.convo != null: 
			if conversation.onetime && !conversation.done:
				conversation.done = true
				cur_conv = conversations.find(conversation) + 1
				return conversation.convo
			elif !conversation.done:
				cur_conv += conversations.find(conversation)
				return conversation.convo
	return null
