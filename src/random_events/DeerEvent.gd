extends Control

func _ready():
	show_window("Intro")

func show_window(window_name):
	for window in get_children():
		if window_name in window.name:
			window.show()
		else:
			window.hide()

func _on_IntroWindow_option_0_pressed():
	AudioManager.play_sound("PlayerTookDamage")
	var health_loss = 2 + Globals.current_floor
	Globals.remove_health(health_loss)
	if randi() % 2 == 0:
		show_window("BloodNothing")
	else:
		show_window("BloodStrength")

func _on_IntroWindow_option_1_pressed():
	var heal_amount = 2 + Globals.current_floor
	Globals.add_health(heal_amount)
	AudioManager.play_sound("PlayerHealed")
	show_window("EatWindow")

func _on_IntroWindow_option_2_pressed():
	show_window("Ignore")

func _on_EatWindow_option_0_pressed():
	pass

func _on_BloodStrengthWindow_option_0_pressed():
	var chosen_display_card = Globals.get_random_display_card()
	var chosen_card_data = chosen_display_card.card.duplicate()
	chosen_card_data.damage += 1
	chosen_display_card.finish_modification(chosen_card_data)
	AudioManager.play_sound("CardUpgraded")
