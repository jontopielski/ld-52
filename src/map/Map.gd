extends Control

const HeartTexture = preload("res://sprites/symbols/Heart.png")
const Home = preload("res://resources/map_nodes/Home.tres")
const MapNode = preload("res://src/map/MapNode.tscn")
const EmptyNode = preload("res://resources/map_nodes/Empty.tres")
const PLAYER_NODE_OFFSET = Vector2(7, 10)

export(Array, Resource) var test_map_nodes = []
export(Array, Resource) var random_events = []

var current_node = null
var node_queue = []

func _ready():
	update_ui()
	if Globals.current_map_node:
		generate_map(false)
		for i in range(0, len(Globals.current_map)):
			var node_queue_resource = Globals.current_map[i]
			var node_queue_position = Globals.node_queue_positions[i]
			var next_map_node = MapNode.instance()
			$MapNodes.add_child(next_map_node)
			next_map_node.rect_position = node_queue_position
			next_map_node.set_map_node(node_queue_resource)
			node_queue.push_back(next_map_node)
		current_node = node_queue.front()
		$Player.position = node_queue.front().rect_position + PLAYER_NODE_OFFSET
	else:
		generate_map()
		setup_node_queue()
		save_node_queue()
		current_node = node_queue.front()
		current_node.set_map_node(Home)
		$Player.position = node_queue.front().rect_position + PLAYER_NODE_OFFSET
		if !test_map_nodes.empty():
			for i in range(0, min(len(node_queue), len(test_map_nodes))):
				if test_map_nodes[i].name == "Random":
					randomize()
					node_queue[i + 1].set_map_node(random_events[randi() % len(random_events)])
				else:
					node_queue[i + 1].set_map_node(test_map_nodes[i])

func _process(delta):
	if OS.is_debug_build() and Input.is_action_just_pressed("ui_jump_to_battle"):
		change_to_battle()

func update_ui():
	$TopBar/Health/Count.text = "%02d/%02d" % [Globals.current_health, Globals.max_health]

func event_finished():
	$CardDisplay.load_cards()
	$TopBar/ContinueButton.show()

func is_walking():
	return $AnimationPlayer.current_animation == "walk"

func walk_to_next_node():
	Globals.current_index += 1
	node_queue.push_back(node_queue.pop_front())
	var next_node = node_queue.front()
	if next_node.rect_position.x < current_node.rect_position.x:
		$Player.flip_h = false
	else:
		$Player.flip_h = true
	$AnimationPlayer.play("walk")
	var TWEEN_TIME = $Player.position.distance_to(next_node.rect_position + PLAYER_NODE_OFFSET) / 20.0
	$Tween.interpolate_property($Player, "position", $Player.position, next_node.rect_position + PLAYER_NODE_OFFSET, TWEEN_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	yield(get_tree().create_timer(.125), "timeout")
	$AnimationPlayer.play("idle")
	yield(get_tree().create_timer(.125), "timeout")
	current_node = next_node
	
	if current_node.map_node.event != null:
		spawn_event(current_node.map_node.event)
	elif "Enemy" in current_node.map_node.name or "Boss" in current_node.map_node.name:
		change_to_battle()
	else:
		$TopBar/ContinueButton.show()

func spawn_event(event):
	var next_event = event.instance()
	$Events.add_child(next_event)

func save_node_queue():
	var saved_node_queue = []
	var node_queue_positions = []
	for map_node in node_queue:
		saved_node_queue.push_back(map_node.map_node)
		node_queue_positions.push_back(map_node.rect_position)
	Globals.node_queue_positions = node_queue_positions
	Globals.current_map = saved_node_queue

func change_to_battle():
	Globals.current_map_node = current_node.map_node
	save_node_queue()
	TransitionScreen.transition_to(Globals.Battle)

func generate_map(spawn_map_nodes = true):
	var points = $Path.points
	for i in range(0, len(points)):
		points[i] += $Path.position
	if spawn_map_nodes:
		for point in points:
			var next_map_node = MapNode.instance()
			$MapNodes.add_child(next_map_node)
			next_map_node.rect_position = point + Vector2(-5, -5)
			next_map_node.set_map_node(EmptyNode)
	points.push_back(points[0])

func setup_node_queue():
	var furthest_west_node = $MapNodes.get_child(0)
	for map_node in $MapNodes.get_children():
		if map_node.rect_position.x < furthest_west_node.rect_position.x:
			furthest_west_node = map_node
	var west_node_child_index = 0
	for i in range(0, $MapNodes.get_child_count()):
		if $MapNodes.get_child(i) == furthest_west_node:
			west_node_child_index = i
	node_queue.push_back($MapNodes.get_child(west_node_child_index))
	for i in range(west_node_child_index + 1, $MapNodes.get_child_count()):
		node_queue.push_back($MapNodes.get_child(i))
	for i in range(0, west_node_child_index):
		node_queue.push_back($MapNodes.get_child(i))

func _on_ContinueButton_pressed():
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
