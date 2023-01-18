extends Control

func _ready():
	$About.hide()

func _on_Play_pressed():
	TransitionScreen.transition_to(Globals.Map)

func _on_Options_pressed():
	SettingsMenu.show_menu()

func _on_Quit_pressed():
	get_tree().quit()

func _on_About_pressed():
	$Open.play()
	$About.show()

func _on_CloseButton_pressed():
	$Close.play()
	$About.hide()
