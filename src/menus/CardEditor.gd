extends Control

const ShopTab = preload("res://src/map/ShopTab.tscn")

export(int) var max_tabs_per_row = 3

var cards = []

func _ready():
	var resources = []
	var dir = Directory.new()
	var card_paths = get_resources_at_path("res://resources/cards")
	for card_path in card_paths:
		cards.push_back(load(card_path))
	cards.sort_custom(SortNameAscending, "sort_ascending")
	setup_tabs()
	display_item(cards.front())

func display_item(card):
	$Card.set_card(card)
	if card.description == "":
		$Description.text = "NO DESCRIPTION SET!"
	else:
		$Description.text = card.description

func setup_tabs():
	for i in range(0, len(cards)):
		var next_tab = ShopTab.instance()
		get_next_tab_to_use().add_child(next_tab)
		next_tab.set_resource(cards[i], false)
	yield(get_tree().create_timer(0.05), "timeout")
	$Tabs.get_child(0).get_child(0).pressed = true

func get_next_tab_to_use():
	for tab in $Tabs.get_children():
		if tab.get_child_count() < max_tabs_per_row:
			return tab
	max_tabs_per_row += 1
	return get_next_tab_to_use()

func get_resources_at_path(path):
	var resources = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if dir.current_is_dir() and file_name != "." and file_name != "..":
			var nested_resources = get_resources_at_path(path + "/" + file_name)
			for rsc in nested_resources:
				resources.push_back(rsc)
		elif file_name != "." and file_name != ".." and file_name.ends_with(".tres"):
			resources.push_back(path + "/" + file_name)
		file_name = dir.get_next()
	
	return resources

class SortNameAscending:
	static func sort_ascending(a, b):
		if a.name < b.name:
			return true
		return false
