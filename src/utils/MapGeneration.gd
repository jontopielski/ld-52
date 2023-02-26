extends Node

onready var starting_queues = {
	"home_cards": get_initial_home_cards(),
	"enemy_cards": get_initial_enemy_cards(),
	"elite_cards": [],
	"boss_cards": get_initial_boss_cards(),
	"bonus_nodes": get_initial_bonus_nodes()
}

onready var current_queues = get_initial_current_queues()

func get_next_home_card():
	return process_options(pop_queue("home_cards"))

func get_next_enemy_card():
	return process_options(pop_queue("enemy_cards"))

func get_next_boss_card():
	return process_options(pop_queue("boss_cards"))

func process_options(initial_nodes):
	randomize()
	var processed_nodes = []
	for nodes in initial_nodes:
		var next_nodes = []
		for node in nodes:
			if node == Enums.MapNodeType.BONUS:
				next_nodes.push_back(pop_queue("bonus_nodes"))
			else:
				next_nodes.push_back(node)
		if len(nodes) >= 2:
			next_nodes.shuffle()
		processed_nodes.push_back(next_nodes)
	return processed_nodes

func pop_queue(queue_name):
	if current_queues[queue_name].empty():
		current_queues[queue_name] = starting_queues[queue_name].duplicate()
		randomize();
		current_queues[queue_name].shuffle()
	return current_queues[queue_name].pop_front()

func get_initial_bonus_nodes():
	return [
		Enums.MapNodeType.RELIC,
		Enums.MapNodeType.REMOVE,
		Enums.MapNodeType.FUSION,
		Enums.MapNodeType.UPGRADE,
		Enums.MapNodeType.IMBUE
	]

func get_initial_current_queues():
	var queues = {}
	for starting_key in starting_queues.keys():
		queues[starting_key] = []
	return queues

func get_initial_enemy_cards():
	return [
		[
			[Enums.MapNodeType.NONE],
			[Enums.MapNodeType.ENEMY],
			[Enums.MapNodeType.LESS_THAN],
			[Enums.MapNodeType.RANDOM, Enums.MapNodeType.BONUS],
			[Enums.MapNodeType.EQUALS],
			[Enums.MapNodeType.ENEMY, Enums.MapNodeType.ENEMY],
			[Enums.MapNodeType.NONE],
		],
		[
			[Enums.MapNodeType.NONE],
			[Enums.MapNodeType.RANDOM, Enums.MapNodeType.ENEMY],
			[Enums.MapNodeType.GREATER_THAN],
			[Enums.MapNodeType.BONUS],
			[Enums.MapNodeType.DASH],
			[Enums.MapNodeType.ENEMY],
			[Enums.MapNodeType.NONE],
		],
		[
			[Enums.MapNodeType.NONE],
			[Enums.MapNodeType.RANDOM],
			[Enums.MapNodeType.LESS_THAN],
			[Enums.MapNodeType.BONUS, Enums.MapNodeType.BONUS],
			[Enums.MapNodeType.EQUALS],
			[Enums.MapNodeType.RANDOM, Enums.MapNodeType.ENEMY],
			[Enums.MapNodeType.NONE],
		],
		[
			[Enums.MapNodeType.NONE],
			[Enums.MapNodeType.BONUS, Enums.MapNodeType.BONUS],
			[Enums.MapNodeType.GREATER_THAN],
			[Enums.MapNodeType.ENEMY],
			[Enums.MapNodeType.LESS_THAN],
			[Enums.MapNodeType.RANDOM, Enums.MapNodeType.ENEMY],
			[Enums.MapNodeType.NONE],
		],
	]

func get_initial_boss_cards():
	return [
		[
			[Enums.MapNodeType.NONE],
			[Enums.MapNodeType.BONUS],
			[Enums.MapNodeType.LESS_THAN],
			[Enums.MapNodeType.ENEMY, Enums.MapNodeType.ENEMY],
			[Enums.MapNodeType.GREATER_THAN],
			[Enums.MapNodeType.BOSS],
			[Enums.MapNodeType.NONE],
		],
		[
			[Enums.MapNodeType.NONE],
			[Enums.MapNodeType.ENEMY, Enums.MapNodeType.RANDOM],
			[Enums.MapNodeType.GREATER_THAN],
			[Enums.MapNodeType.BONUS],
			[Enums.MapNodeType.DASH],
			[Enums.MapNodeType.BOSS],
			[Enums.MapNodeType.NONE],
		],
		[
			[Enums.MapNodeType.NONE],
			[Enums.MapNodeType.BONUS, Enums.MapNodeType.BONUS],
			[Enums.MapNodeType.EQUALS],
			[Enums.MapNodeType.ENEMY, Enums.MapNodeType.RANDOM],
			[Enums.MapNodeType.GREATER_THAN],
			[Enums.MapNodeType.BOSS],
			[Enums.MapNodeType.NONE],
		],
		[
			[Enums.MapNodeType.NONE],
			[Enums.MapNodeType.ENEMY],
			[Enums.MapNodeType.LESS_THAN],
			[Enums.MapNodeType.BONUS, Enums.MapNodeType.BONUS],
			[Enums.MapNodeType.GREATER_THAN],
			[Enums.MapNodeType.BOSS],
			[Enums.MapNodeType.NONE],
		],
	]

func get_initial_home_cards():
	return [
		[
			[Enums.MapNodeType.NONE],
			[Enums.MapNodeType.HOME],
			[Enums.MapNodeType.DASH],
			[Enums.MapNodeType.ENEMY],
			[Enums.MapNodeType.LESS_THAN],
			[Enums.MapNodeType.RANDOM, Enums.MapNodeType.ENEMY],
			[Enums.MapNodeType.NONE],
		],
		[
			[Enums.MapNodeType.NONE],
			[Enums.MapNodeType.HOME],
			[Enums.MapNodeType.DASH],
			[Enums.MapNodeType.ENEMY],
			[Enums.MapNodeType.LESS_THAN],
			[Enums.MapNodeType.ENEMY, Enums.MapNodeType.RANDOM],
			[Enums.MapNodeType.NONE],
		],
		[
			[Enums.MapNodeType.NONE],
			[Enums.MapNodeType.HOME],
			[Enums.MapNodeType.LESS_THAN],
			[Enums.MapNodeType.RANDOM, Enums.MapNodeType.ENEMY],
			[Enums.MapNodeType.GREATER_THAN],
			[Enums.MapNodeType.ENEMY],
			[Enums.MapNodeType.NONE],
		],
		[
			[Enums.MapNodeType.NONE],
			[Enums.MapNodeType.HOME],
			[Enums.MapNodeType.LESS_THAN],
			[Enums.MapNodeType.ENEMY, Enums.MapNodeType.ENEMY],
			[Enums.MapNodeType.GREATER_THAN],
			[Enums.MapNodeType.RANDOM],
			[Enums.MapNodeType.NONE],
		],
	]
