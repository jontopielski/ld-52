extends CanvasLayer

export(bool) var hide_menu_at_start = true

var use_white_cursor = true

func _ready():
	if hide_menu_at_start:
		get_tree().paused = false
		$Menu.hide()
	$Menu/Background/Options/Sliders/FullscreenBox.pressed = OS.window_fullscreen

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if $Menu.visible:
			hide_menu()
		else:
			show_menu()

func show_menu():
	$Open.play()
	get_tree().paused = true
	$Menu.show()

func hide_menu():
	$Close.play()
	get_tree().paused = false
	$Menu.hide()

func _on_CloseButton_pressed():
	SettingsMenu.hide_menu()

func _on_CloseButton_mouse_entered():
	return
	get_tree().call_group("Terminal", "set_terminal_text", ": Close Settings", $Menu/Background/TopBar/CloseButton.texture_hover)

func _on_CloseButton_mouse_exited():
	return
	get_tree().call_group("Terminal", "clear_terminal_text")

func _on_FullscreenBox_toggled(button_pressed):
	$Beep.play()
	if button_pressed:
		$Menu/BlackBox.show()
	OS.window_fullscreen = button_pressed
	$Menu/BlackBox.hide()

func _on_SFXSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), -pow(1.55, 10 - value))
	$SFXBeep.pitch_scale = 1.0 + (value / 10.0)
	$SFXBeep.play()
	
func _on_PaletteSlider_value_changed(value):
	$Beep.play()
	PaletteManager.set_palette(int(value) / 2)

func _on_MusicSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), -pow(1.55, 10 - value))

func _on_WhiteCursorBox_toggled(button_pressed):
	use_white_cursor = button_pressed
	CursorManager.update_all_cursors()
