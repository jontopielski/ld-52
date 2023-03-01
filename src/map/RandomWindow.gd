tool
extends PanelContainer

export(String) var title = "Random Event" setget set_title
export(String) var description = "The event description.." setget set_description
export(Array, String) var option_names = ["Option_1"] setget set_option_names
export(Array, Array, Resource) var option_icons = [] setget set_option_icons

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
