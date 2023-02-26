extends Control

export(Resource) var map_node = null setget set_map_node

func _ready():
	$StackedShadows.hide()
	$StackedSprite.hide()

func set_map_node(_map_node):
	map_node = _map_node
	if map_node:
		self_modulate.a = 0.0
		$StackedSprite.set_texture(map_node.texture)
		$StackedSprite.show()
		for shadow in $StackedShadows.get_children():
			shadow.set_texture(map_node.texture)
		$StackedShadows.show()

func set_sprites_random_rotation():
	randomize()
	var possible_angles = [-60, -30, -15, 15, 30, 60]
	var random_angle = possible_angles[randi() % len(possible_angles)]
	$StackedSprite.set_sprite_rotation(random_angle)
	$StackedSprite.rotation_sum = random_angle
	for shadow in $StackedShadows.get_children():
		shadow.set_sprite_rotation(random_angle)
		shadow.rotation_sum = random_angle

func start_spinning():
	$StackedSprite.rotate_sprites = true
	for shadow in $StackedShadows.get_children():
		shadow.rotate_sprites = true

func stop_spinning():
	$StackedSprite.rotate_sprites = false
	for shadow in $StackedShadows.get_children():
		shadow.rotate_sprites = false

func _on_MapNode_mouse_entered():
	start_spinning()
	get_tree().call_group("Terminal", "set_terminal_text", "%s: %s" % [map_node.name, map_node.description], map_node.icon)

func _on_MapNode_mouse_exited():
	stop_spinning()
	get_tree().call_group("Terminal", "clear_terminal_text")
