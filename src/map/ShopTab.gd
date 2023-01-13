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
	else:
		add_stylebox_override("pressed", BottomTabPressed)

func _ready():
	set_is_top_tab(is_top_tab)
	if resource:
		set_resource(resource)

func unpress_if_not_id(id):
	if get_instance_id() != id:
		pressed = false

func set_resource(_resource):
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
	text = symbol + "^" + resource.name.to_upper() + "^%d$" % resource.cost

func _on_ShopTab_toggled(button_pressed):
	if button_pressed:
		get_tree().call_group("shop_tabs", "unpress_if_not_id", get_instance_id())
		get_tree().call_group("Shop", "display_item", resource, item_type)
