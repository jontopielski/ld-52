extends ColorRect

func _ready():
	clear_terminal_text()

func set_terminal_text(text, texture = null):
	$ClearTimer.stop()
	$HBox/Label.text = text
	if texture:
		$HBox/Icon.show()
		$HBox/Icon.texture = texture
	else:
		$HBox/Icon.hide()

func clear_terminal_text():
	$ClearTimer.start()

func _on_ClearTimer_timeout():
	$HBox/Label.text = ""
	$HBox/Icon.hide()
