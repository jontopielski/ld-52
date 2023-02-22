extends Control

func _ready():
	$About.hide()
	Globals.reset_all_state()

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel") and $About.visible:
		$Close.play()
		$About.hide()

func _on_Play_pressed():
	TransitionScreen.transition_to(Globals.Map)

func _on_Options_pressed():
	SettingsMenu.show_menu()

func _on_Quit_pressed():
	TransitionScreen.transition_to(Globals.BlackScreen)

func _on_About_pressed():
	$Open.play()
	$About.show()

func _on_CloseButton_pressed():
	$Close.play()
	$About.hide()

func is_about_visible():
	return $About.visible
