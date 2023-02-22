extends CanvasLayer

func _ready():
	$Example.hide()

func show_crt():
	$CRT.show()

func hide_crt():
	$CRT.hide()

func set_darkness(darkness):
	$CRT.material.set_shader_param("darkness", darkness)

func set_white_color(color):
	$CRT.material.set_shader_param("white_color", color)
