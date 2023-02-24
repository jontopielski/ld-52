extends Control

export(Array, String) var sprite_paths = []
export(Array, Texture) var additional_sprites = []

func _ready():
	var sprites = []
	for sprite_path in sprite_paths:
		var next_sprites = get_sprites_at_path(sprite_path)
		for next_sprite in next_sprites:
			sprites.push_back(next_sprite)
	$Center/Grid.columns = int(sqrt(len(sprites))) + 1
	for sprite in sprites:
		var next_texture = TextureRect.new()
		next_texture.texture = sprite
		$Center/Grid.add_child(next_texture)
	for sprite in additional_sprites:
		var next_texture = TextureRect.new()
		next_texture.texture = sprite
		$Center/Grid.add_child(next_texture)

func get_sprites_at_path(path):
	var sprites = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if dir.current_is_dir() and file_name != "." and file_name != "..":
			var nested_resources = get_sprites_at_path(path + "/" + file_name)
			for rsc in nested_resources:
				sprites.push_back(rsc)
		elif file_name != "." and file_name != ".." and file_name.ends_with(".png"):
			sprites.push_back(load(path + "/" + file_name))
		file_name = dir.get_next()

	return sprites
