extends Control

var good_result = 0

func _ready():
	randomize()
	good_result = randi() % 2
	if good_result == 0:
		$EscapeWindow.set_description($EscapeWindow.description % ["Heads"])
		$SuccessWindow.set_description($SuccessWindow.description % ["Heads"])
		$FailureWindow.set_description($FailureWindow.description % ["Heads"])
	else:
		$EscapeWindow.set_description($EscapeWindow.description % ["Tails"])
		$SuccessWindow.set_description($SuccessWindow.description % ["Tails"])
		$FailureWindow.set_description($FailureWindow.description % ["Tails"])
	show_window("Intro")

func show_window(window_name):
	for window in get_children():
		if window_name in window.name:
			window.show()
		else:
			window.hide()

func _on_IntroWindow_option_2_pressed():
	show_window("Ignore")

func _on_IntroWindow_option_0_pressed():
	var selected_result = 0
	if selected_result == good_result:
		AudioManager.play_sound("RandomEventSuccess")
		show_window("Success")
	else:
		if randi() % 2 == 0:
			AudioManager.play_sound("RandomEventNext")
			show_window("Escape")
		else:
			AudioManager.play_sound("RandomEventFailure")
			show_window("Failure")

func _on_IntroWindow_option_1_pressed():
	var selected_result = 1
	if selected_result == good_result:
		AudioManager.play_sound("RandomEventSuccess")
		show_window("Success")
	else:
		AudioManager.play_sound("RandomEventFailure")
		show_window("Failure")

func _on_SuccessWindow_option_0_pressed():
	Globals.add_max_health(1)
	AudioManager.play_sound("PlayerGainedMaxHp")

func _on_FailureWindow_option_0_pressed():
	Globals.remove_max_health(1)
	AudioManager.play_sound("PlayerLostMaxHp")

func _on_EscapeWindow_option_0_pressed():
	pass # Replace with function body.
