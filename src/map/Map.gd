extends Control

const Home = preload("res://resources/map_nodes/Home.tres")
const MapNode = preload("res://src/map/MapNode.tscn")
const PLAYER_NODE_OFFSET = Vector2(7, 10)

export(Array, Resource) var test_map_nodes = []

var current_node = null
var node_queue = []

func _ready():
	generate_map()
	setup_node_queue()
	current_node = node_queue.front()
	current_node.set_map_node(Home)
	$Player.position = node_queue.front().rect_position + PLAYER_NODE_OFFSET
	if !test_map_nodes.empty():
		for i in range(0, min(len(node_queue), len(test_map_nodes))):
			node_queue[i + 1].set_map_node(test_map_nodes[i])

func _process(delta):
	if Input.is_action_just_pressed("ui_tab"):
		if $Shop.visible:
			close_shop()
		else:
			open_shop()
	if OS.is_debug_build() and Input.is_action_just_pressed("ui_jump_to_battle"):
		change_to_battle()

func open_shop():
	$Open.play()
	$Shop.show()
	$TopBar/ContinueButton.hide()
	$ShopButton.text = "MAP"

func close_shop():
	$Close.play()
	$Shop.hide()
	$TopBar/ContinueButton.show()
	$ShopButton.text = "SHOP"

func walk_to_next_node():
	node_queue.push_back(node_queue.pop_front())
	var next_node = node_queue.front()
	if next_node.rect_position.x < current_node.rect_position.x:
		$Player.flip_h = false
	else:
		$Player.flip_h = true
	$AnimationPlayer.play("walk")
	$Tween.interpolate_property($Player, "position", $Player.position, next_node.rect_position + PLAYER_NODE_OFFSET, $Player.position.distance_to(next_node.rect_position + PLAYER_NODE_OFFSET) / 15.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	yield(get_tree().create_timer(.2), "timeout")
	current_node = next_node
	if current_node.map_node.node_type == Enums.NodeType.BATTLE:
		change_to_battle()
	else:
		$AnimationPlayer.play("idle")
		$Player.flip_h = false
		$TopBar/ContinueButton.show()

func change_to_battle():
	Globals.current_map_node = current_node.map_node
	get_tree().change_scene_to(Globals.Battle)

func generate_map():
	var points = $PolygonPath.polygon
	for i in range(0, len(points)):
		points[i] += $PolygonPath.position
	for point in points:
		var next_map_node = MapNode.instance()
		$MapNodes.add_child(next_map_node)
		next_map_node.rect_position = point + Vector2(-5, -5)
	points.push_back(points[0])
	$Path.points = points
	$PolygonPath.hide()

func setup_node_queue():
	var furthest_east_node = $MapNodes.get_child(0)
	for map_node in $MapNodes.get_children():
		if map_node.rect_position.x > furthest_east_node.rect_position.x:
			furthest_east_node = map_node
	var east_node_child_index = 0
	for i in range(0, $MapNodes.get_child_count()):
		if $MapNodes.get_child(i) == furthest_east_node:
			east_node_child_index = i
	node_queue.push_back($MapNodes.get_child(east_node_child_index))
	for i in range(east_node_child_index + 1, $MapNodes.get_child_count()):
		node_queue.push_back($MapNodes.get_child(i))
	for i in range(0, east_node_child_index):
		node_queue.push_back($MapNodes.get_child(i))

func _on_ContinueButton_pressed():
	$Continue.play()
	$TopBar/ContinueButton.hide()
	get_tree().call_group("Terminal", "clear_terminal_text")
	walk_to_next_node()

func _on_AlphaSort_pressed():
	$CardDisplay.sort_cards_by_name()

func _on_GoldSort_pressed():
	$CardDisplay.sort_cards_by_gold()

func _on_DamageSort_pressed():
	$CardDisplay.sort_cards_by_damage()

func _on_AlphaSort_mouse_entered():
	get_tree().call_group("Terminal", "set_terminal_text", ": Sort cards by name", $AlphaSort.texture_pressed)

func _on_GoldSort_mouse_entered():
	get_tree().call_group("Terminal", "set_terminal_text", ": Sort cards by gold", $GoldSort.texture_pressed)

func _on_DamageSort_mouse_entered():
	get_tree().call_group("Terminal", "set_terminal_text", ": Sort cards by damage", $DamageSort.texture_pressed)

func _on_Sort_mouse_exited():
	get_tree().call_group("Terminal", "clear_terminal_text")

func _on_ShopButton_pressed():
	if $Shop.visible:
		close_shop()
	else:
		open_shop()

func _on_ConfirmButton_pressed():
	pass # Replace with function body.

func _on_ShopButton_mouse_entered():
	get_tree().call_group("Terminal", "set_terminal_text", "Open the shop (tab)")

func _on_MapButton_mouse_entered():
	get_tree().call_group("Terminal", "set_terminal_text", "Return to the map")

func _on_ContinueButton_mouse_entered():
	get_tree().call_group("Terminal", "set_terminal_text", "Travel to the next point")
