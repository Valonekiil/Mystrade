extends Node

var tween
@onready var DialogueBox #= $Panel
@onready var Dialogue #= $Panel/Label
@onready var timer #= $Timer

var dialogue_to_me = [
	"Halo diriku yang ada disana?",
	"Apakah kamu menyesal?",
	"Berdoalah dia tetap memilikinya",
	"otherwise it's all useless"
]
var ftime:bool = true
var dialogue_conv = []
var dialogue_index = 0
var dialogue_finished:bool = false
var dialogue_stopper = 0
var convo:Dialog_Convo

func _ready():
	#Dialogue.rect_global_position = Vector2(-13,700)
	#Dialogue.visible = false
	#$Timer.timeout.connect(on_timer_timeout)
	pass

func load_dialogue(index:Dialog_Convo):
	if ftime:
		print("first time = " + index.resource_name)
		convo = index
		dialogue_conv = index.lines
		ftime = false
		get_tree().paused = true
		#GlobalSignal.impaused = true
	
	
	Dialogue.visible = true
	if dialogue_index < dialogue_conv.size():
		print("dialog ke " + str(dialogue_index))
		dialogue_finished = false
		Dialogue.text = dialogue_conv[dialogue_index]
		Dialogue.visible_ratio = 0
		tween = create_tween()
		tween.connect("finished",self.on_tween_finished)
		tween.tween_property(Dialogue, "visible_ratio", 1, 1).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		tween.play()
	else :
		print("dialog ended")
		Dialogue.visible = false
		DialogueBox.dial_hide()
		dialogue_index = -1
		convo = null
		dialogue_stopper = 0
		ftime = true
		get_tree().paused = false
		#GlobalSignal.impaused = false
	dialogue_index += 1

func on_tween_finished():
	dialogue_finished = true
	$Timer.start()
	

func on_timer_timeout():
	print("conv done")

func next_dialogue() -> void:
	load_dialogue(convo)
