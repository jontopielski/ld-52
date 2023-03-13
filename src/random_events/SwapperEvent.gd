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
	show_window("Ignore")

func _on_IntroWindow_option_0_pressed():
	AudioManager.play_sound("RandomEventNext")
	show_window("Swap")
	$SwapWindow.spawn_in()

func _on_SwapWindow_modification_finished():
	$SwapWindow.queue_free()
	show_window("End")
