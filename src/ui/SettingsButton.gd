extends TextureButton

func _on_SettingsButton_mouse_entered():
	get_tree().call_group("Terminal", "set_terminal_text", ": Open Settings", texture_hover)

func _on_SettingsButton_mouse_exited():
	get_tree().call_group("Terminal", "clear_terminal_text")

func _on_SettingsButton_pressed():
	SettingsMenu.show_menu()
