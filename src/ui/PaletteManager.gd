extends CanvasLayer

export(Array, Color) var whites = []
export(Array, Color) var blacks = []

func _ready():
	set_palette(0)

func set_palette(index):
	$Shader.material.set_shader_param("ColorOne", whites[index])
	$Shader.material.set_shader_param("ColorTwo", blacks[index])
	CursorManager.update_all_cursors()

func get_current_white_color():
	return Color.white if SettingsMenu.use_white_cursor else $Shader.material.get_shader_param("ColorOne")
