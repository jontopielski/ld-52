extends Node

const Battle = preload("res://src/battle/Battle.tscn")
const Map = preload("res://src/map/Map.tscn")
const MainMenu = preload("res://src/menus/MainMenu.tscn")

const RARITY_PROBABILITIES = {
	Enums.Rarity.COMMON: 0.70,
	Enums.Rarity.MEDIUM: 0.20,
	Enums.Rarity.RARE: 0.07,
	Enums.Rarity.VERY_RARE: 0.03,
	Enums.Rarity.ULTRA_RARE: 0.01
}

export(Array, Resource) var deck = []
export(Array, Resource) var test_deck = []

export(Resource) var current_map_node = null
export(bool) var show_basic_hints = true

var current_node_queue_resources = []
var node_queue_positions = []

export(int) var max_health = 5
export(int) var current_health = 5

func _ready():
	if !test_deck.empty():
		deck = test_deck

func _process(delta):
	if OS.is_debug_build() and Input.is_action_just_pressed("ui_reset"):
		var current_scene_path = get_tree().current_scene.filename
		get_tree().change_scene(current_scene_path)
	if OS.is_debug_build() and Input.is_action_just_pressed("ui_screenshot"):
		var image = get_viewport().get_texture().get_data()
		image.flip_y()
		image.save_png("C:\\Users\\jonto\\Desktop\\Game_Screenshot_%s.png" % str(randi() % 1000))

func get_card_symbol():
	return "`"

func get_map_node_symbol():
	return "}"

func get_reroll_symbol():
	return "|"

func get_relic_symbol():
	return "~"

func get_randomized_item_from_list(items):
	var items_by_rarity = {
		Enums.Rarity.COMMON: get_all_items_with_rarity(items, Enums.Rarity.COMMON),
		Enums.Rarity.MEDIUM: get_all_items_with_rarity(items, Enums.Rarity.MEDIUM),
		Enums.Rarity.RARE: get_all_items_with_rarity(items, Enums.Rarity.RARE),
		Enums.Rarity.VERY_RARE: get_all_items_with_rarity(items, Enums.Rarity.VERY_RARE),
		Enums.Rarity.ULTRA_RARE: get_all_items_with_rarity(items, Enums.Rarity.ULTRA_RARE)
	}
	var randomized_item = null
	while !randomized_item:
		var next_rarity = get_randomized_rarity()
		var items_list_with_rarity = items_by_rarity[next_rarity]
		if !items_list_with_rarity.empty():
			items_list_with_rarity.shuffle()
			randomized_item = items_list_with_rarity.front()
	return randomized_item

func get_randomized_rarity():
	randomize()
	var possible_rarities = []
	for rarity_probability in RARITY_PROBABILITIES.keys():
		var probability = RARITY_PROBABILITIES[rarity_probability]
		for i in range(0, int(probability * 100)):
			possible_rarities.push_back(rarity_probability)
	possible_rarities.shuffle()
	return possible_rarities[randi() % len(possible_rarities)]

func get_all_items_with_rarity(items, rarity):
	var items_with_rarity = []
	for item in items:
		if item.rarity == rarity:
			items_with_rarity.push_back(item)
	return items_with_rarity
