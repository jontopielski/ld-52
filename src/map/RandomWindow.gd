tool
extends PanelContainer

signal option_0_pressed
signal option_1_pressed
signal option_2_pressed

const RewardWindowPost = preload("res://src/battle/RewardWindowPost.tres")

export(String) var title = "Random Event" setget set_title
export(String) var description = "The event description.." setget set_description
export(Array, String) var option_names = ["Option_1"] setget set_option_names
export(Array, Array, Resource) var option_icons = [] setget set_option_icons

func _ready():
	spawn_in()

func spawn_in():
	rect_pivot_offset = Globals.current_map_node_rect_position - rect_position + Vector2(4, 4)
	$Cover.show()
	$Content.hide()
	var tween_time = 0.4
	rect_scale = Vector2.ZERO
	$Tween.interpolate_property(self, "rect_scale", Vector2.ZERO, Vector2.ONE, tween_time, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()

func update_random_options():
	if !has_node("Content"):
		return
	var options_count = min(len(option_names), len(option_icons))
	for i in range(0, $Content/Items.get_child_count()):
		var next_child = $Content/Items.get_child(i)
		if i >= options_count:
			next_child.hide()
		else:
			next_child.show()
			next_child.set_description(option_names[i])
			next_child.set_icons(option_icons[i])

func set_option_icons(_option_icons):
	option_icons = _option_icons
	update_random_options()

func set_option_names(_option_names):
	option_names = _option_names
	update_random_options()

func set_title(_title):
	title = _title
	if has_node("Content/Title"):
		$Content/Title.text = title

func set_description(_description):
	description = _description
	if has_node("Content/TextMargin/Description"):
		$Content/TextMargin/Description.text = description

func _on_RandomOption_0_pressed():
	emit_signal("option_0_pressed")

func _on_RandomOption_1_pressed():
	emit_signal("option_1_pressed")

func _on_RandomOption_2_pressed():
	emit_signal("option_2_pressed")

func _on_Tween_tween_all_completed():
	add_stylebox_override("panel", RewardWindowPost)
	$Content.show()
	$Cover.hide()
