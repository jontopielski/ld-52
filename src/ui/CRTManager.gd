extends CanvasLayer

func _ready():
	$Example.hide()

func show_crt():
	$CRT.show()

func hide_crt():
	$CRT.hide()
