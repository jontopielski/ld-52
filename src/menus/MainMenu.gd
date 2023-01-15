extends Control

export(bool) var erase_button_names = false

func _ready():
	if erase_button_names:
		$Options/Start.text = ""
		$Options/Settings.text = ""
		$Options/Quit.text = ""
	else:
		$Options/Start/TextImage.hide()
		$Options/Settings/TextImage.hide()
		$Options/Quit/TextImage.hide()

func _on_Settings_pressed():
	SettingsMenu.show_menu()

func _on_Quit_pressed():
	get_tree().quit()

func _on_Start_pressed():
	get_tree().change_scene_to(Globals.Map)
