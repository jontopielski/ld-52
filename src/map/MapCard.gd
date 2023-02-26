extends TextureRect

onready var map_card = null setget set_map_card

func set_map_card(_map_card):
	map_card = _map_card
	render_map_card()

func render_map_card():
	for i in range(0, len(map_card)):
		var map_card_data = map_card[i]
		var current_vbox = get_node("HBox/VBox_%d" % i)
		if len(map_card_data) == 1 and !is_edge(i):
			current_vbox.get_child(1).queue_free()
		for j in range(0, len(map_card_data)):
			var map_node_type = map_card_data[j]
			current_vbox.get_child(j).set_map_node_type(map_node_type)

func is_edge(index):
	return index % 2 == 0

func get_map_node_objs():
	var map_nodes = []
	for vbox in $HBox.get_children():
		var nodes = []
		for map_node in vbox.get_children():
			if "MapNode" in map_node.name and !map_node.is_queued_for_deletion():
				nodes.push_back(map_node)
		if !nodes.empty():
			map_nodes.push_back(nodes)
	return map_nodes
