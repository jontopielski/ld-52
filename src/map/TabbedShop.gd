extends Control

const ShopTab = preload("res://src/map/ShopTab.tscn")

export(Array, Resource) var example_items = []

export(int) var STARTING_TABS = 6

func _ready():
	setup_tabs()

func display_item(resource, item_type):
	match item_type:
		Enums.ItemType.CARD:
			display_card(resource)
		Enums.ItemType.MAP_NODE:
			display_map_node(resource)

func display_card(card):
	$Content/StackedSprite.hide()
	$Content/CardStats.show()

	$Content/CardStats.set_card(card)
	$Content/Description.text = card.description

func display_map_node(map_node):
	$Content/StackedSprite.show()
	$Content/CardStats.hide()
	
	$Content/StackedSprite.set_texture(map_node.texture)
	$Content/Description.text = map_node.description

func setup_tabs():
	clear_all_shop_tabs()
	for i in range(0, STARTING_TABS):
		var next_tab = ShopTab.instance()
		if $TopTabs.get_child_count() > $BottomTabs.get_child_count():
			$BottomTabs.add_child(next_tab)
			next_tab.set_is_top_tab(false)
		else:
			$TopTabs.add_child(next_tab)
			next_tab.set_is_top_tab(true)
		next_tab.set_resource(example_items[i])
	yield(get_tree().create_timer(0.05), "timeout")
	for i in range(0, $TopTabs.get_child_count()):
		$TopTabs.get_child(i).trim_item_name_if_necessary($TopTabs.get_child_count(), get_max_name_size($TopTabs.get_child_count()))
	for i in range(0, $BottomTabs.get_child_count()):
		$BottomTabs.get_child(i).trim_item_name_if_necessary($BottomTabs.get_child_count(), get_max_name_size($BottomTabs.get_child_count()))
	yield(get_tree().create_timer(0.05), "timeout")
	$TopTabs.get_child(0).pressed = true

func get_max_name_size(child_count):
	match child_count:
		2:
			return 15
		3:
			return 8
		4:
			return 5
		5:
			return 3
	return 15

func clear_all_shop_tabs():
	for tab in $TopTabs.get_children():
		tab.queue_free()
	for tab in $BottomTabs.get_children():
		tab.queue_free()
