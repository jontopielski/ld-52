extends Control

const continue_icon = preload("res://resources/icons/Continue.tres")

var reward_relic = null

func _ready():
	show_window("Intro")

func show_window(window_name):
	for window in get_children():
		if window_name in window.name:
			window.show()
		else:
			window.hide()

func _on_IntroWindow_option_0_pressed():
	if randi() % 2 == 0:
		AudioManager.play_sound("RandomEventSuccess")
		show_window("Success")
		reward_relic = Globals.get_next_relic()
		$SuccessWindow.option_icons[0] = [reward_relic]
		$SuccessWindow.set_option_names(["Take '%s'" % reward_relic.name])
	else:
		AudioManager.play_sound("RandomEventFailure")
		if Globals.current_health >= int(Globals.max_health / 2):
			var hp_reduced = 2 + Globals.current_floor
			$FailureHpWindow.set_option_names(["Lose %d hp" % hp_reduced])
			show_window("FailureHp")
		else:
			var max_hp_reduced = 1 + Globals.current_floor
			$FailureMaxHpWindow.set_option_names(["Lose %d max hp" % max_hp_reduced])
			show_window("FailureMaxHp")

func _on_IntroWindow_option_1_pressed():
	show_window("Ignore")

func _on_FailureMaxHpWindow_option_0_pressed():
	var max_hp_reduced = 1 + Globals.current_floor
	Globals.remove_max_health(max_hp_reduced)
	AudioManager.play_sound("PlayerLostMaxHp")

func _on_FailureHpWindow_option_0_pressed():
	var hp_reduced = 2 + Globals.current_floor
	Globals.remove_health(hp_reduced)
	AudioManager.play_sound("PlayerTookDamage")

func _on_SuccessWindow_option_0_pressed():
	AudioManager.play_sound("ReceivedRelic")
	Globals.add_relic(reward_relic)
	$SuccessWindow.end_event()
