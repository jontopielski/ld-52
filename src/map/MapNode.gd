extends Button

export(Enums.MapNodeType) var map_node_type = Enums.MapNodeType.HOME setget set_map_node_type
export(Array, Resource) var icons = []

func set_map_node_type(_map_node_type):
	map_node_type = _map_node_type
	$Icon.set_icon(icons[map_node_type])

func set_past(visited = false):
	$AnimationPlayer.stop()
	disabled = true
	$Icon.inverted = visited
	mouse_default_cursor_shape = Control.CURSOR_ARROW

func set_current():
	$AnimationPlayer.stop()
	disabled = true
	$Icon.inverted = true
	mouse_default_cursor_shape = Control.CURSOR_ARROW

func set_next(index=0):
	if index % 2 == 0:
		$AnimationPlayer.play("clickable")
	else:
		$AnimationPlayer.play("clickable_opposite")
	$Icon.flip_h = false
	disabled = false
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func set_unreachable():
	$AnimationPlayer.stop()
	$Icon.flip_h = false
	disabled = true
	$Icon.inverted = false
	mouse_default_cursor_shape = Control.CURSOR_ARROW

func invert_if_not_hovering(set_inverted):
	if !get_global_rect().encloses(Rect2(get_global_mouse_position(), Vector2.ZERO)):
		$Icon.inverted = set_inverted

func _on_MapNode_mouse_entered():
	if !disabled:
		$Icon.inverted = true

func _on_MapNode_mouse_exited():
	if !disabled:
		$Icon.inverted = false

func _on_MapNode_pressed():
	set_current()
	get_tree().call_group("Map", "map_node_pressed", self)
