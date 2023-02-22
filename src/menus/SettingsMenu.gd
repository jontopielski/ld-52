extends CanvasLayer

const CursorColored = preload("res://sprites/settings/CursorOutlineColored.png")
const CursorWhite = preload("res://sprites/settings/CursorOutlineWhite.png")

export(bool) var hide_menu_at_start = true

var use_white_cursor = true

func _ready():
	set_all_audiostream_volumes(-80)
	$Menu/Window/Options/Sliders/YouSureButton.hide()
	$Menu/Window/Options/Sliders/Hints/BasicHints.pressed = Globals.show_basic_hints
	if hide_menu_at_start:
		get_tree().paused = false
		$Menu.hide()
	$Menu/Window/Options/Sliders/FullscreenBox.pressed = OS.window_fullscreen
	if $Menu/Window/Options/Sliders/Palette/WhiteCursorBox.pressed:
		$Menu/Window/Options/Names/Palette/Mouse.texture = CursorWhite
	else:
		$Menu/Window/Options/Names/Palette/Mouse.texture = CursorColored

func set_all_audiostream_volumes(volume_db):
	for child in get_children():
		if child is AudioStreamPlayer:
			child.volume_db = volume_db

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel") and !TransitionScreen.is_transitioning:
		if $Menu.visible:
			hide_menu()
		else:
			if get_tree().current_scene.name == "MainMenu" and get_tree().current_scene.is_about_visible():
				return
			else:
				show_menu()

func show_menu():
	$Menu/Window/Options/Sliders/YouSureButton.hide()
	$Menu/Window/Options/Sliders/AbandonButton.show()
	$Open.play()
	get_tree().paused = true
	$Menu.show()

func hide_menu(play_sound=true):
	if play_sound:
		$Close.play()
	get_tree().paused = false
	$Menu.hide()

func _on_CloseButton_pressed():
	SettingsMenu.hide_menu()

func _on_CloseButton_mouse_entered():
	return
	get_tree().call_group("Terminal", "set_terminal_text", ": Close Settings", $Menu/Window/CloseButton.texture_hover)

func _on_CloseButton_mouse_exited():
	return
	get_tree().call_group("Terminal", "clear_terminal_text")

func _on_FullscreenBox_toggled(button_pressed):
	if button_pressed:
		$CheckboxOn.play()
		$Menu/BlackBox.show()
	else:
		$CheckboxOff.play()
	OS.window_fullscreen = button_pressed
	$Menu/BlackBox.hide()

func _on_SFXSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear2db(value / 10.0))
	$SFXBeep.pitch_scale = 1.0 + (value / 10.0)
	$SFXBeep.play()
	
func _on_PaletteSlider_value_changed(value):
	$Beep.play()
	PaletteManager.set_palette_index(int(value) / 2)

func _on_MusicSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(value / 10.0))

func _on_WhiteCursorBox_toggled(button_pressed):
	use_white_cursor = button_pressed
	CursorManager.update_all_cursors()
	if button_pressed:
		$CheckboxOn.play()
	else:
		$CheckboxOff.play()

func _on_BasicHints_toggled(button_pressed):
	Globals.show_basic_hints = button_pressed
	if button_pressed:
		$CheckboxOn.play()
	else:
		$CheckboxOff.play()

func _on_WhiteCursorBox_mouse_entered():
	if $Menu/Window/Options/Sliders/Palette/WhiteCursorBox.pressed:
		$Menu/Window/Options/Names/Palette/Mouse.texture = CursorColored
	else:
		$Menu/Window/Options/Names/Palette/Mouse.texture = CursorWhite

func _on_WhiteCursorBox_mouse_exited():
	if $Menu/Window/Options/Sliders/Palette/WhiteCursorBox.pressed:
		$Menu/Window/Options/Names/Palette/Mouse.texture = CursorWhite
	else:
		$Menu/Window/Options/Names/Palette/Mouse.texture = CursorColored

func _on_CRTBox_toggled(button_pressed):
	if button_pressed:
		$CheckboxOn.play()
		CRTManager.show_crt()
	else:
		$CheckboxOff.play()
		CRTManager.hide_crt()

func _on_AbandonButton_pressed():
	$AbandonWarning.play()
	$Menu/Window/Options/Sliders/AbandonButton.hide()
	$Menu/Window/Options/Sliders/YouSureButton.show()

func _on_YouSureButton_pressed():
	hide_menu(false)
	$Abandon.play()
	TransitionScreen.transition_to(Globals.MainMenu)

func _on_InitializationTimer_timeout():
	set_all_audiostream_volumes(0)
