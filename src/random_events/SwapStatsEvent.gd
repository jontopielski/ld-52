extends Control

func _ready():
	show_window("Intro")

func show_window(window_name):
	for window in get_children():
		if window_name in window.name:
			window.show()
		else:
			window.hide()

func _on_IntroWindow_option_1_pressed():
	AudioManager.play_sound("RandomEventIgnore")
	show_window("Ignore")
