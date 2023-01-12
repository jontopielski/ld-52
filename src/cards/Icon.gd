tool
extends TextureRect

export(Resource) var icon = null setget set_icon
export(bool) var inverted = false setget set_inverted

var is_using_manual_mouse_entered = false
var is_manual_hovering = false

func set_icon(_icon):
	icon = _icon
	if Engine.editor_hint:
		render_current_icon()

func set_inverted(_inverted):
	inverted = _inverted
	material.set_shader_param("inverted", inverted)

func _ready():
	render_current_icon()

func _process(delta):
	if is_using_manual_mouse_entered:
		if get_global_rect().encloses(Rect2(get_global_mouse_position(), Vector2.ZERO)):
			if !is_manual_hovering:
				get_tree().call_group("Terminal", "set_terminal_text", get_icon_text(), texture)
				is_manual_hovering = true
		elif is_manual_hovering:
			get_tree().call_group("Terminal", "clear_terminal_text")
			is_manual_hovering = false

func render_current_icon():
	if !icon:
		return
	texture = icon.texture

func get_icon_text():
	return icon.name + ": " + icon.description

func _on_Icon_mouse_entered():
	get_tree().call_group("Terminal", "set_terminal_text", get_icon_text(), texture)

func _on_Icon_mouse_exited():
	get_tree().call_group("Terminal", "clear_terminal_text")
