tool
extends TextureRect

export(Enums.MapNodeType) var map_node_type = Enums.MapNodeType.DASH setget set_map_node_type
var is_front_edge = false setget set_is_front_edge
var is_back_edge = false setget set_is_back_edge

export(Array, Texture) var edges = []

func set_is_front_edge(_is_front_edge):
	is_front_edge = _is_front_edge

func set_is_back_edge(_is_back_edge):
	is_back_edge = _is_back_edge

func set_map_node_type(_map_node_type):
	map_node_type = _map_node_type
	match map_node_type:
		Enums.MapNodeType.DASH:
			texture = edges[0]
		Enums.MapNodeType.LESS_THAN:
			texture = edges[1]
		Enums.MapNodeType.GREATER_THAN:
			texture = edges[2]
		Enums.MapNodeType.EQUALS:
			texture = edges[3]
		Enums.MapNodeType.CROSS:
			texture = edges[4]
		Enums.MapNodeType.NONE:
			texture = edges[5]
