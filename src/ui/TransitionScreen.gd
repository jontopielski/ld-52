extends CanvasLayer

func _ready():
	hide_all_textures()

func hide_all_textures():
	for child in get_children():
		if child is TextureRect:
			child.hide()

func transition_to(next_scene):
	var is_main_menu = false
	hide_all_textures()
	if "MainMenu" in get_tree().current_scene.name:
		is_main_menu = true
		$Circle.material.set_shader_param("visible_diameter", 0.0)
		$Circle.texture = get_screenshot_texture()
		$Circle.show()
	elif next_scene == Globals.Map:
		$ReverseClamp.material.set_shader_param("percent_visible", 0.0)
		$ReverseClamp.texture = get_screenshot_texture()
		$ReverseClamp.show()
	else:
		$Clamp.material.set_shader_param("percent_visible", 1.0)
		$Clamp.texture = get_screenshot_texture()
		$Clamp.show()

	get_tree().change_scene_to(next_scene)

	if next_scene == Globals.Battle:
		$AnimationPlayer.play("fast_clamp_in")
	elif is_main_menu:
		yield(get_tree().create_timer(0.05), "timeout")
		$AnimationPlayer.play("circle_out")
	elif next_scene == Globals.Map:
		$AnimationPlayer.play("reverse_clamp_out")
	else:
		$AnimationPlayer.play("clamp_in")

func _on_AnimationPlayer_animation_finished(anim_name):
	hide_all_textures()

func get_screenshot_texture():
	var texture = ImageTexture.new()
	var image = get_viewport().get_texture().get_data()
	image.flip_y()
	texture.create_from_image(image)
	return texture
