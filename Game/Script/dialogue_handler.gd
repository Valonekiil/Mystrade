extends Node

@onready var DialogueBox = $Panel
@onready var Dialogue = $Panel/Label
@onready var timer #= $Timer

signal finished
var dialogue_to_me = [
	"Halo diriku yang ada disana?",
	"Apakah kamu menyesal?",
	"Berdoalah dia tetap memilikinya",
	"otherwise it's all useless"]
var trading:bool
var is_talking:bool
var ftime:bool = true
var dialogue_conv = []
var dialogue_index = 0
var dialogue_finished:bool = false
var dialogue_stopper = 0
var convo:Dialog_Convo
var conversations: Array[Convo_Res]
var cur_conv:int = 0 
var twin:Tween
var current_item:Item_Base

func load_dialogue(index:Dialog_Convo ):
	if ftime:
		print("first time = " + index.resource_name)
		convo = index
		dialogue_conv = index.lines
		ftime = false
		get_tree().paused = true
		#GlobalSignal.impaused = true
	DialogueBox.visible = true
	Dialogue.visible = true
	if dialogue_index < dialogue_conv.size():
		is_talking = true
		print("dialog ke " + str(dialogue_index))
		var raw_text = dialogue_conv[dialogue_index]
		var final_text = replace_placeholders(raw_text, current_item)
		Dialogue.text = final_text
		dialogue_finished = false
		#Dialogue.text = dialogue_conv[dialogue_index]
		Dialogue.visible_ratio = 0
		var duration = Dialogue.text.length() * 0.05
		var tween = create_tween()
		twin = tween
		tween.connect("finished",self.on_tween_finished)
		tween.tween_property(Dialogue, "visible_ratio", 1, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		tween.play()
		await tween.finished
	else :
		print("dialog ended")
		trading = true
		Dialogue.visible = false
		DialogueBox.visible = false
		dialogue_index = -1
		convo = null
		dialogue_stopper = 0
		ftime = true
		get_tree().paused = false
		is_talking = false
		finished.emit()
		#GlobalSignal.impaused = false
	dialogue_index += 1

func replace_placeholders(text: String, item: Item_Base) -> String:
	if item == null:
		return text
	
	var result = text
	result = result.replace("%v", str(item.get_scaled_price()))  # Harga setelah scaling
	result = result.replace("%n", item.name)                    # Nama item
	result = result.replace("%s", str(item.scaling))           # Scaling value
	result = result.replace("%w", str(item.worth))             # Harga dasar
	result = result.replace("%d", item.desc)                   # Deskripsi
	return result

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_SPACE) and is_talking:
		if is_talking and dialogue_finished:
			next_dialogue()
		elif is_talking and twin.is_running():
			twin.finished.emit()
			twin.kill()
			Dialogue.visible_ratio = 1
		elif get_tree().current_scene.cur_cus != null and !is_talking:
			current_item = get_tree().current_scene.cur_cus.item
			conversations = current_item.dialogue
			talking()

func on_tween_finished():
	dialogue_finished = true

func talking():
	for conversation in conversations:
		if conversation.convo != null: 
			if !conversation.done:
				cur_conv += conversations.find(conversation)
				load_dialogue(conversation.convo)
		print("ngobrol ")
	print("gak ada topik lagi")
	return null

func next_dialogue() -> void:
	load_dialogue(convo)
