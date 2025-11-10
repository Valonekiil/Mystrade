# SimpleCircleTransition.gd
extends CanvasLayer

signal finished
signal finished_texturing
@onready var circle_sprite: Sprite2D = $CircleSprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var target_scene: String = ""

func _ready():
	create_circle_texture()
	circle_sprite.visible = false

func create_circle_texture():
	# Buat texture circle hitam
	var image = Image.create(512, 512, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	var center = Vector2(256, 256)
	for x in 512:
		for y in 512:
			var dist = center.distance_to(Vector2(x, y))
			if dist <= 256:  # Radius 256
				image.set_pixel(x, y, Color.BLACK)
	
	var texture = ImageTexture.create_from_image(image)
	circle_sprite.texture = texture
	circle_sprite.scale = Vector2(0.01, 0.01) 
	finished_texturing.emit()

func create_inverse_mask_texture():
	var image = Image.create(512, 512, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)  # ⬅️ GANTI JADI PUTIH BESAR!
	
	var center = Vector2(256, 256)
	for x in 512:
		for y in 512:
			var dist = center.distance_to(Vector2(x, y))
			if dist <= 256:  # Dalam circle jadi TRANSPARAN
				image.set_pixel(x, y, Color.TRANSPARENT)
	
	var texture = ImageTexture.create_from_image(image)
	circle_sprite.texture = texture
	circle_sprite.scale = Vector2(0.01, 0.01)
	finished_texturing.emit()

func transition_to_scene(scene_path: String):
	target_scene = scene_path
	circle_sprite.modulate = Color.BLACK
	circle_sprite.visible = true
	create_circle_texture()
	circle_sprite.scale = Vector2(0.01, 0.01)
	animation_player.play("circle_grow")

func _on_animation_finished(anim_name: String)-> void:
	match anim_name:
		"circle_grow":
			get_tree().change_scene_to_file(target_scene)
			animation_player.play("fade_out")
		
		"fade_out":
			circle_sprite.visible = false
			
	finished.emit()

func play(v:String):
	animation_player.play(v)
