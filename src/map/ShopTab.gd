extends Button

const TopTabPressed = preload("res://src/map/ShopTabTopPressed.tres")
const BottomTabPressed = preload("res://src/map/ShopTabBottomPressed.tres")

export(bool) var is_top_tab = true setget set_is_top_tab
export(Resource) var resource = null setget set_resource

var item_type = Enums.ItemType.NONE

func set_is_top_tab(_is_top_tab):
	is_top_tab = _is_top_tab
	if is_top_tab:
		add_stylebox_override("pressed", TopTabPressed)
		add_stylebox_override("disabled", TopTabPressed)
	else:
		add_stylebox_override("pressed", BottomTabPressed)
		add_stylebox_override("disabled", BottomTabPressed)

func _ready():
	set_is_top_tab(is_top_tab)
	if resource:
		set_resource(resource)

func unpress_if_not_id(id):
	if get_instance_id() != id:
		pressed = false

func set_resource(_resource, show_symbols=true):
	resource = _resource
	var symbol = ""
	match resource.resource_path.split("/")[3]:
		"cards":
			item_type = Enums.ItemType.CARD
			symbol = Globals.get_card_symbol()
		"map_nodes":
			item_type = Enums.ItemType.MAP_NODE
			symbol = Globals.get_map_node_symbol()
		"relics":
			item_type = Enums.ItemType.RELIC
			symbol = Globals.get_relic_symbol()
	if show_symbols:
		text = symbol + "/" + resource.name.to_upper()
	else:
		text = resource.name.to_upper()

func trim_item_name_if_necessary(child_count, max_characters_in_name):
	var current_name_split = text.split("/")
	var updated_name = current_name_split[1].substr(0, max_characters_in_name)
	text = current_name_split[0] + "/" + updated_name + "/" + current_name_split[2]

func _on_ShopTab_toggled(button_pressed):
	if button_pressed:
		get_tree().call_group("shop_tabs", "unpress_if_not_id", get_instance_id())
		get_tree().call_group("Shop", "display_item", resource, item_type)
		get_tree().call_group("Editor", "display_item", resource)
		disabled = true
	else:
		disabled = false
