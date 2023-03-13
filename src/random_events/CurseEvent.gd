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
	var chosen_display_card = Globals.get_random_display_card()
	var chosen_card_data = chosen_display_card.card.duplicate()
	var random_negative_effect = Globals.get_next_negative_effect()
	while random_negative_effect in chosen_card_data.effects:
		random_negative_effect = Globals.get_next_negative_effect()
	chosen_card_data.effects.push_back(random_negative_effect)
	chosen_display_card.finish_modification(chosen_card_data)
	AudioManager.play_sound("RandomEventCursed")
