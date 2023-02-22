extends CanvasLayer

export(Array, Color) var whites = []
export(Array, Color) var blacks = []

export(bool) var randomize_palette = false

func _ready():
	randomize()
	if randomize_palette:
		set_palette_index(randi() % len(whites))

func swap_black_white():
	var current_white = $Shader.material.get_shader_param("ColorOne")
	var current_black = $Shader.material.get_shader_param("ColorTwo")
	$Shader.material.set_shader_param("ColorOne", current_black)
	$Shader.material.set_shader_param("ColorTwo", current_white)

func set_palette_index(index):
	$Shader.material.set_shader_param("ColorOne", whites[index])
	$Shader.material.set_shader_param("ColorTwo", blacks[index])
	CursorManager.update_all_cursors()
	CRTManager.set_white_color(whites[index])

func get_current_white_color():
	return Color.white if SettingsMenu.use_white_cursor else $Shader.material.get_shader_param("ColorOne")

func set_palette(white, black):
	$Shader.material.set_shader_param("ColorOne", white)
	$Shader.material.set_shader_param("ColorTwo", black)
	CursorManager.update_all_cursors()
