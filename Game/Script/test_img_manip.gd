extends TextureRect

func save_texture_with_modulate_resized():
	if texture == null:
		push_error("Texture is null!")
		return
	
	var original_image = texture.get_image()
	
	var target_width = int(size.x)
	var target_height = int(size.y)
	
	var resized_image = Image.create(target_width, target_height, false, Image.FORMAT_RGBA8)
	
	original_image.resize(target_width, target_height, Image.INTERPOLATE_LANCZOS)
	
	for x in range(target_width):
		for y in range(target_height):
			var original_color = original_image.get_pixel(x, y)
			var modulated_color = original_color * modulate
			resized_image.set_pixel(x, y, modulated_color)
	
	resized_image.save_png("res://texture_resized_with_modulate.png")
	print("Resized texture saved!")

func _ready() -> void:
	await get_tree().process_frame
	save_texture_with_modulate_resized()
