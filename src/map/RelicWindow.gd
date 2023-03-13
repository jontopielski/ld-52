extends Control

const Continue = preload("res://resources/icons/Continue.tres")

var relics = []

export(int) var relic_count = 2

func _ready():
	var option_names = []
	var option_icons = []
	for i in range(0, relic_count):
		var next_relic = Globals.get_next_relic()
		relics.push_back(next_relic)
		option_names.push_back("Choose '%s'" % next_relic.name)
		option_icons.push_back([next_relic])
	$IntroWindow.set_option_icons(option_icons)
	$IntroWindow.set_option_names(option_names)

func relic_selected(relic):
	AudioManager.play_sound("ReceivedRelic")
	$IntroWindow.show_mouse_block()
	get_tree().call_group("Terminal", "clear_terminal_text")
	yield(get_tree().create_timer(0.65), "timeout")
	Globals.add_relic(relic)
	get_tree().call_group("Map", "event_finished")

func _on_IntroWindow_option_0_pressed():
	relic_selected(relics[0])

func _on_IntroWindow_option_1_pressed():
	relic_selected(relics[1])

func _on_IntroWindow_option_2_pressed():
	relic_selected(relics[2])
