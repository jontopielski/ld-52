tool
extends Button

export(String) var description = "Placeholder" setget set_description
export(Array, Resource) var icons = [] setget set_icons

func set_icons(_icons):
	icons = _icons
	if !has_node("Symbols"):
		return
	for i in range(0, $Symbols.get_child_count()):
		var next_child = $Symbols.get_child(i)
		if i >= len(icons):
			next_child.hide()
		else:
			next_child.show()
			next_child.set_icon(icons[i])

func set_description(_description):
	description = _description
	if has_node("Label"):
		$Label.text = description

func _process(delta):
	if pressed and !get_global_rect().encloses(Rect2(get_global_mouse_position(), Vector2.ZERO)) and $Label.get_color("font_color") == Color.white:
		set_everything_black()
	elif pressed and get_global_rect().encloses(Rect2(get_global_mouse_position(), Vector2.ZERO)) and $Label.get_color("font_color") == Color.black:
		set_everything_white()

func set_everything_white():
	$Label.add_color_override("font_color", Color.white)
	set_symbols_inverted(true)

func set_everything_black():
	$Label.add_color_override("font_color", Color.black)
	set_symbols_inverted(false)

func set_symbols_inverted(inverted):
	for symbol in $Symbols.get_children():
		if symbol is TextureRect:
			symbol.inverted = inverted
		elif symbol is Label:
			if inverted:
				symbol.add_color_override("font_color", Color.white)
			else:
				symbol.add_color_override("font_color", Color.black)

func _on_RandomOption_mouse_entered():
	if !disabled:
		set_everything_white()

func _on_RandomOption_mouse_exited():
	if !disabled:
		set_everything_black()

func is_relic_window():
	if get_tree().current_scene.name == "Map":
		return get_tree().current_scene.is_relic_window_open()
	return false

func _on_RandomOption_pressed():
	if is_relic_window():
		$AnimationPlayer.play("flash")
