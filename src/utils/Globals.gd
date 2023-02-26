extends Node

const Battle = preload("res://src/battle/Battle.tscn")
const Map = preload("res://src/map/Map.tscn")
const MainMenu = preload("res://src/menus/MainMenu.tscn")
const BlackScreen = preload("res://src/ui/BlackScreen.tscn")

export(bool) var show_debug_values = false
export(Array, Resource) var starting_deck = []
export(Array, Resource) var deck = [].duplicate()
export(Array, Resource) var rewards = []
export(Array, Resource) var relics = [].duplicate()
export(bool) var show_basic_hints = true

var current_map = []
var current_map_node = Enums.MapNodeType.HOME

var current_floor = 0
var current_index = 0
var current_map_node_position = Enums.MapNodePosition.MIDDLE
var visited_map_node_positions = [Enums.MapNodePosition.MIDDLE]

export(int) var max_health = 8
export(int) var current_health = 8

onready var reward_to_cooldown_map = initialize_reward_to_cooldown_map()

onready var starting_queues = {
	"enemy_effects": get_all_enemy_effects(),
	"enemy_counts": [1, 1, 1, 2, 2, 2, 3],
	"2_enemy_weights": [[.7, .4], [.8, .4], [.5, .7], [.65, .55]],
	"3_enemy_weights": [[.8, .3, .3], [.5, .4, .3], [.7, .2, .4], [.4, .4, .4]],
	"card_effect_type": [00, 00, 00, -10, -11, 01, 01, 01, 01], # xy = (negative, positive)
	"positive_effects": get_all_positive_effects(),
	"negative_effects": get_all_negative_effects(),
}

onready var current_queues = get_initial_current_queues()

func _ready():
	initialize_queues()
	initialize_starting_deck()

func get_initial_current_queues():
	var queues = {}
	for starting_key in starting_queues.keys():
		queues[starting_key] = []
	return queues

func has_reward(reward_name):
	for reward in rewards:
		if reward.name == reward_name:
			return true
	return false

func remove_reward(reward):
	reward_to_cooldown_map.erase(reward)
	rewards.erase(reward)

func add_reward(reward):
	reward_to_cooldown_map[reward] = 0
	if "Cards" in reward.name:
		rewards.push_front(reward)
	else:
		rewards.push_back(reward)

func initialize_reward_to_cooldown_map():
	var map = {}
	for reward in rewards:
		map[reward] = 0
	return map

func is_facing_boss():
	return current_map_node == Enums.MapNodeType.BOSS

func has_relic(relic_name):
	for relic in relics:
		if relic.name == relic_name:
			return true
	return false

func initialize_starting_deck():
	deck.clear()
	if !starting_deck.empty():
		for starting_card in starting_deck:
			deck.push_back(starting_card.duplicate())
		deck.back().effects.push_back(get_next_positive_effect())
		return
	var starting_card_weight = 1.1
	var card_weight_increment = 0.1
	var total_hand_weight = 0.0
	for i in range(0, 5):
		var card_weight = starting_card_weight + (i * card_weight_increment)
		var next_card = CardGeneration.generate_card(card_weight, true)
		total_hand_weight += Sort.get_card_weight(next_card)
		deck.push_back(next_card)
	if total_hand_weight > 10.0 or get_total_cards_with_shield(deck) < 2 or get_total_cards_with_damage(Globals.deck) < 2:
		print("Starting hand weight of %.2f was too high!" % [total_hand_weight])
		initialize_starting_deck()

func get_total_cards_with_shield(hand):
	var shield_count = 0
	for card in hand:
		if card.shield > 0:
			shield_count += 1
	return shield_count

func get_total_cards_with_damage(hand):
	var damage_count = 0
	for card in hand:
		if card.damage > 0:
			damage_count += 1
	return damage_count

func initialize_queues():
	randomize()
	for starting_queue in starting_queues.keys():
		current_queues[starting_queue] = starting_queues[starting_queue].duplicate()
		current_queues[starting_queue].shuffle()

func reset_all_state():
	initialize_queues()
	initialize_starting_deck()
	current_map_node = null
	current_map = []
	current_floor = 0
	current_index = 0
	max_health = 8
	current_health = 8
	CardGeneration.generated_cards.clear()

func get_next_positive_effect():
	return pop_queue("positive_effects")

func get_next_negative_effect():
	return pop_queue("negative_effects")

func get_next_card_effect_type():
	return pop_queue("card_effect_type")

func get_next_enemy_count():
	return pop_queue("enemy_counts")

func pop_queue(queue_name):
	if current_queues[queue_name].empty():
		current_queues[queue_name] = starting_queues[queue_name].duplicate()
		randomize();
		current_queues[queue_name].shuffle()
	return current_queues[queue_name].pop_front()

func get_all_positive_effects():
	var positive_effects = get_resources_at_path("res://resources/effects/positive")
	for positive_effect in positive_effects:
		if positive_effect.is_testing:
			return [positive_effect]
	return positive_effects

func get_all_negative_effects():
	var negative_effects = get_resources_at_path("res://resources/effects/negative")
	for negative_effect in negative_effects:
		if negative_effect.is_testing:
			return [negative_effect]
	return negative_effects

func add_health(health):
	current_health = min(max_health, current_health + health)
	get_tree().call_group("ui", "update_ui")

func get_next_enemy_effect(enemy_count):
	var effect_to_return = pop_queue("enemy_effects")
	if effect_to_return.is_multi_only and enemy_count == 1:
		return get_next_enemy_effect(enemy_count)
	elif effect_to_return.is_solo_only and enemy_count > 1:
		return get_next_enemy_effect(enemy_count)
	elif effect_to_return.minimum_index > current_index:
		return get_next_enemy_effect(enemy_count)
	else:
		return effect_to_return

func get_all_enemy_effects():
	var effects = get_resources_at_path("res://resources/enemy_effects/")
	var effects_to_remove = []
	for effect in effects:
		if !effect.is_starting_effect:
			effects_to_remove.push_back(effect)
	for effect in effects_to_remove:
		effects.erase(effect)
	randomize(); effects.shuffle()
	return effects

func _process(delta):
	if OS.is_debug_build() and Input.is_action_just_pressed("ui_reset"):
		if get_tree().current_scene.name == "Battle" or get_tree().current_scene.name == "Map":
			CardGeneration.generated_cards.clear()
			initialize_starting_deck()
		else:
			reset_all_state()
		var current_scene_path = get_tree().current_scene.filename
		get_tree().change_scene(current_scene_path)
	if OS.is_debug_build() and Input.is_action_just_pressed("ui_screenshot"):
		randomize()
		var image = get_viewport().get_texture().get_data()
		image.flip_y()
		image.save_png("C:\\Users\\jonto\\Desktop\\Game_Screenshot_%s.png" % str(randi() % 1000))

func remove_card(_card):
	for card in deck:
		if card == _card:
			deck.erase(card)
			break

func get_resources_at_path(path, load_them=true):
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
			if load_them:
				resources.push_back(load(path + "/" + file_name))
			else:
				resources.push_back(path + "/" + file_name)
		file_name = dir.get_next()
	
	return resources
