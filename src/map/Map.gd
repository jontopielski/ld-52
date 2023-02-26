extends Control

signal finished_walking

const HeartTexture = preload("res://sprites/symbols/Heart.png")
const Home = preload("res://resources/map_nodes/Home.tres")
const MapNode = preload("res://src/map/MapNode.tscn")
const PLAYER_NODE_OFFSET = Vector2(3, 3)

export(Array, Resource) var test_map_nodes = []
export(Array, Resource) var random_events = []

var current_node = null
var next_node = null
var current_map = []
var map_card_objs = []
var map_node_objs = []

func _ready():
	update_ui()
	setup_map_cards()
	if Globals.current_map:
		current_map = Globals.current_map
	else:
		generate_map()
		Globals.current_map = current_map
	load_current_map()
	update_map_nodes()

func map_node_pressed(selected_map_node):
	Globals.current_index += 1
	var map_nodes = map_node_objs[Globals.current_index]
	for i in range(0, len(map_nodes)):
		var map_node = map_nodes[i]
		if map_node == selected_map_node:
			var node_position = get_map_node_position_from_index(i, len(map_nodes))
			Globals.current_map_node_position = node_position
			Globals.visited_map_node_positions.push_back(node_position)
			if i == 0 and len(map_nodes) >= 2:
				map_nodes[i+1].set_unreachable()
			elif i == 1 and len(map_nodes) >= 2:
				map_nodes[i-1].set_unreachable()
	walk_to_next_map_node(selected_map_node)
	yield(self, "finished_walking")
	handle_next_node()
	yield(get_tree().create_timer(0.5), "timeout")
	update_map_nodes()

func handle_next_node():
	Globals.current_map_node = get_current_map_node_type()
	match Globals.current_map_node:
		Enums.MapNodeType.ENEMY:
			change_to_battle()

func walk_to_next_map_node(selected_node):
	$AnimationPlayer.play("walk")
	var TWEEN_TIME = 1.0
	$Tween.interpolate_property($Player, "position", $Player.position, selected_node.rect_global_position + get_player_position_offset(), TWEEN_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	yield(get_tree().create_timer(.125), "timeout")
	$AnimationPlayer.play("idle")
	yield(get_tree().create_timer(.25), "timeout")
	emit_signal("finished_walking")

func update_map_nodes():
	for i in range(0, len(map_node_objs)):
		var map_nodes = map_node_objs[i]
		if i < Globals.current_index:
			for j in range(0, len(map_nodes)):
				var map_node = map_nodes[j]
				var map_node_position = get_map_node_position_from_index(j, len(map_nodes))
				var visited_node = map_node_position == Globals.visited_map_node_positions[i]
				map_node.set_past(visited_node)
		elif i == Globals.current_index:
			for j in range(0, len(map_nodes)):
				var map_node_position = get_map_node_position_from_index(j, len(map_nodes))
				if Globals.current_map_node_position == map_node_position:
					map_nodes[j].set_current()
				else:
					map_nodes[j].set_past()
		elif i == Globals.current_index + 1:
			var next_edge = get_edge_before_map_node_index(i)
			for j in range(0, len(map_nodes)):
				var next_map_node_position = get_map_node_position_from_index(j, len(map_nodes))
				if next_edge == Enums.MapNodeType.EQUALS and next_map_node_position != Globals.current_map_node_position:
					map_nodes[j].set_unreachable()
				else:
					map_nodes[j].set_next(j)
		else:
			for map_node in map_nodes:
				map_node.set_unreachable()
	yield(get_tree().create_timer(0.05), "timeout")
	$Player.position = get_current_map_node().rect_global_position + get_player_position_offset()
	Globals.current_map_node = get_current_map_node_type()

func get_edge_before_map_node_index(node_index):
	var map_index = get_map_array_index(node_index)
	return current_map[map_index - 1].front()

func get_current_map_node():
	return map_node_objs[Globals.current_index][get_map_node_index(Globals.current_map_node_position)]

func get_current_map_node_type():
	return get_current_map_node().map_node_type

func get_player_position_offset():
	match Globals.current_map_node_position:
		Enums.MapNodePosition.TOP:
			return Vector2(5, -3)
		Enums.MapNodePosition.MIDDLE:
			return Vector2(5, 13)
		Enums.MapNodePosition.BOTTOM:
			return Vector2(5, 13)

func get_map_node_index(map_node_position):
	match map_node_position:
		Enums.MapNodePosition.TOP:
			return 0
		Enums.MapNodePosition.MIDDLE:
			return 0
		Enums.MapNodePosition.BOTTOM:
			return 1

func get_map_node_position_from_index(index, array_length):
	if array_length == 1:
		return Enums.MapNodePosition.MIDDLE
	elif array_length == 2 and index == 0:
		return Enums.MapNodePosition.TOP
	else:
		return Enums.MapNodePosition.BOTTOM

func get_map_array_index(node_index):
	var map_card_number = node_index / 3
	return (map_card_number + 1) + (node_index * 2)

func load_current_map():
	for i in range(0, len(map_card_objs)):
		var next_map_card = map_card_objs[i]
		var starting_slice_index = i * 7
		next_map_card.set_map_card(current_map.slice(starting_slice_index, starting_slice_index + 6))
	for map_card in map_card_objs:
		map_node_objs.append_array(map_card.get_map_node_objs())

func generate_map():
	current_map.append_array(MapGeneration.get_next_home_card())
	for i in range(1, len(map_card_objs) - 1):
		current_map.append_array(MapGeneration.get_next_enemy_card())
	current_map.append_array(MapGeneration.get_next_boss_card())
	connect_card_edges()

func connect_card_edges():
	for i in range(6, len(current_map) - 1, 7):
		if len(current_map[i-1]) == 1 and len(current_map[i+2]) == 1:
			current_map[i] = [Enums.MapNodeType.DASH]
			current_map[i+1] = [Enums.MapNodeType.DASH]
		elif len(current_map[i-1]) == 2 and len(current_map[i+2]) == 1:
			current_map[i] = [Enums.MapNodeType.GREATER_THAN]
			current_map[i+1] = [Enums.MapNodeType.GREATER_THAN]
		elif len(current_map[i-1]) == 1 and len(current_map[i+2]) == 2:
			current_map[i] = [Enums.MapNodeType.LESS_THAN]
			current_map[i+1] = [Enums.MapNodeType.LESS_THAN]
		elif len(current_map[i-1]) == 2 and len(current_map[i+2]) == 2:
			current_map[i] = [Enums.MapNodeType.EQUALS]
			current_map[i+1] = [Enums.MapNodeType.EQUALS]

func setup_map_cards():
	match Globals.current_floor:
		0:
			map_card_objs = [
				$MapCardVBox/MapCardHBox_0/MapCard_0,
				$MapCardVBox/MapCardHBox_0/MapCard_1,
				$MapCardVBox/MapCardHBox_0/MapCard_2
			]
			$MapCardVBox/MapCardHBox_1/MapCard_0.queue_free()
			$MapCardVBox/MapCardHBox_1/MapCard_1.queue_free()
			$MapCardVBox/MapCardHBox_1/MapCard_2.queue_free()
		1:
			map_card_objs = [
				$MapCardVBox/MapCardHBox_0/MapCard_0,
				$MapCardVBox/MapCardHBox_0/MapCard_1,
				$MapCardVBox/MapCardHBox_1/MapCard_0,
				$MapCardVBox/MapCardHBox_1/MapCard_1
			]
			$MapCardVBox/MapCardHBox_0/MapCard_2.queue_free()
			$MapCardVBox/MapCardHBox_1/MapCard_2.queue_free()
		2:
			map_card_objs = [
				$MapCardVBox/MapCardHBox_0/MapCard_0,
				$MapCardVBox/MapCardHBox_0/MapCard_1,
				$MapCardVBox/MapCardHBox_0/MapCard_2,
				$MapCardVBox/MapCardHBox_1/MapCard_0,
				$MapCardVBox/MapCardHBox_1/MapCard_1
			]
			$MapCardVBox/MapCardHBox_1/MapCard_2.queue_free()

func _process(delta):
	if OS.is_debug_build() and Input.is_action_just_pressed("ui_jump_to_battle"):
		change_to_battle()

func update_ui():
	$TopBar/Health/Count.text = "%02d/%02d" % [Globals.current_health, Globals.max_health]

func event_finished():
	$CardDisplay.load_cards()

func is_walking():
	return $AnimationPlayer.current_animation == "walk"

func walk_to_next_node():
	Globals.current_index += 1
	$AnimationPlayer.play("walk")
	var TWEEN_TIME = $Player.position.distance_to(next_node.rect_position + PLAYER_NODE_OFFSET) / 20.0
	$Tween.interpolate_property($Player, "position", $Player.position, next_node.rect_position + PLAYER_NODE_OFFSET, TWEEN_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	yield(get_tree().create_timer(.125), "timeout")
	$AnimationPlayer.play("idle")
	yield(get_tree().create_timer(.125), "timeout")
	current_node = next_node
	next_node = null
	
	if current_node.map_node.event != null:
		spawn_event(current_node.map_node.event)
	elif "Enemy" in current_node.map_node.name or "Boss" in current_node.map_node.name:
		change_to_battle()
	else:
		$TopBar/ContinueButton.show()

func spawn_event(event):
	var next_event = event.instance()
	$Events.add_child(next_event)

func change_to_battle():
	TransitionScreen.transition_to(Globals.Battle)

func _on_ContinueButton_pressed():
	return
	$Continue.play()
	$TopBar/ContinueButton.hide()
	get_tree().call_group("Terminal", "clear_terminal_text")
	walk_to_next_node()

func _on_Sort_mouse_exited():
	get_tree().call_group("Terminal", "clear_terminal_text")

func _on_ContinueButton_mouse_entered():
	get_tree().call_group("Terminal", "set_terminal_text", "Travel to the next point")

func _on_Health_mouse_entered():
	get_tree().call_group("Terminal", "set_terminal_text", "HP: current health", HeartTexture)
