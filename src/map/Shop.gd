extends Control

const ShopItem = preload("res://src/map/ShopItem.tscn")

func _ready():
	hide()
	randomize_shop_items()
	yield(get_tree().create_timer(0.05), "timeout")
	show()

func randomize_shop_items():
	clear_items()
	var valid_cards = get_shop_cards()
	randomize(); valid_cards.shuffle()
	for i in range(0, 2):
		var next_item = ShopItem.instance()
		next_item.set_resource(valid_cards[i])
		$Window/Content/Items.add_child(next_item)
	var reroll = ShopItem.instance()
	reroll.set_reroll()
	$Window/Content/Items.add_child(reroll)

func get_shop_cards():
	var cards = []
	var dir = Directory.new()
	var card_paths = Globals.get_resources_at_path("res://resources/cards/shop", false)
	for card_path in card_paths:
		cards.push_back(load(card_path))
	return cards

func get_events():
	var locations = []
	var dir = Directory.new()
	var location_paths = Globals.get_resources_at_path("res://resources/map_nodes", false)
	for location_path in location_paths:
		var next_location = load(location_path)
		if next_location.event != null:
			locations.push_back(next_location)
	return locations

func clear_items():
	for item in $Window/Content/Items.get_children():
		item.queue_free()

func item_selected():
	get_tree().call_group("Map", "event_finished")
	queue_free()

func shop_closed():
	for item in $Window/Content/Items.get_children():
		if item.disabled:
			item.set_everything_white()
		else:
			item.set_everything_black()

func _on_CloseButton_pressed():
	if get_parent().name == "Map":
		get_parent().close_shop()
