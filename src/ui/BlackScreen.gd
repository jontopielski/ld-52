extends ColorRect

func _ready():
	$Smiley.hide()
	$Quit.play()
	yield(get_tree().create_timer(0.7), "timeout")
	$Smiley.show()
	yield(get_tree().create_timer(0.1), "timeout")
	get_tree().quit()
