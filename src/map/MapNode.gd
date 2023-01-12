tool
extends TextureButton

export(Resource) var map_node = null setget set_map_node

func set_map_node(_map_node):
	map_node = _map_node
	if map_node:
		self_modulate.a = 0.0
		$StackedSprite.set_texture(map_node.texture)
		$StackedSprite.show()
		for shadow in $StackedShadows.get_children():
			shadow.set_texture(map_node.texture)
		$StackedShadows.show()

func start_spinning():
	$StackedSprite.rotate_sprites = true
	for shadow in $StackedShadows.get_children():
		shadow.rotate_sprites = true

func stop_spinning():
	$StackedSprite.rotate_sprites = false
	for shadow in $StackedShadows.get_children():
		shadow.rotate_sprites = false

func _on_MapNode_mouse_entered():
	if map_node:
		get_tree().call_group("Terminal", "set_terminal_text", map_node.name + ": " + map_node.description)
	else:
		get_tree().call_group("Terminal", "set_terminal_text", "An empty plot of land")

func _on_MapNode_mouse_exited():
	get_tree().call_group("Terminal", "clear_terminal_text")

func _on_MapNode_toggled(button_pressed):
	if button_pressed:
		$AnimationPlayer.play("blink")
	else:
		$AnimationPlayer.stop()
