extends Control

const HeartTexture = preload("res://sprites/symbols/Health.png")
const Explosion = preload("res://src/effects/Explosion.tscn")
const Card = preload("res://src/cards/Card.tscn")
const Enemy = preload("res://src/cards/Enemy.tscn")

export(Resource) var map_node = null setget set_map_node
export(int) var enemy_count = 1

var INITIAL_HAND_SIZE = 4
var CARD_WIDTH = 36
var CARD_DEAL_TIME_OFFSET = .2

var current_deck = []
var current_discard = []
var current_hand = []

func set_map_node(_map_node):
	map_node = _map_node

func _ready():
	if Globals.current_map_node and Globals.current_map_node.name != "Home":
		set_map_node(Globals.current_map_node)
	else:
		set_map_node(map_node)
	$GameOver.hide()
	$TopBar/ContinueButton.hide()
	$TopBar/EndTurnButton.hide()
	setup_player_deck()
	deal_player_hand()
	spawn_enemies()

func _process(delta):
	if OS.is_debug_build() and Input.is_action_just_pressed("ui_autolose"):
		Globals.current_health = 0
		update_ui()
	elif OS.is_debug_build() and Input.is_action_just_pressed("ui_jump_to_map"):
		TransitionScreen.transition_to(Globals.Map)

func spawn_explosion_at_pos(pos):
	var next_explosion = Explosion.instance()
	$Explosions.add_child(next_explosion)
	next_explosion.position = pos

func spawn_enemies():
	for i in range(0, enemy_count):
		var next_enemy = Enemy.instance()
		next_enemy.set_enemy(map_node.enemies.front())
		$Enemies.add_child(next_enemy)
		var extra_space_at_end = (get_viewport_rect().size.x / enemy_count) - CARD_WIDTH
		next_enemy.spawn_in_from_x_pos(3 + (extra_space_at_end / 2.0) + ((get_viewport_rect().size.x - 8) / enemy_count) * i)
		yield(get_tree().create_timer(0.1), "timeout")

func setup_player_deck():
	randomize()
	current_deck = Globals.deck.duplicate(true)
	current_deck.shuffle()

func update_ui():
	$TopBar/HBox/Deck/Count.text = str(len(current_deck))
	$TopBar/HBox/Discard/Count.text = str(len(current_discard))
	$TopBar/HBox/Health/Count.text = "%d/%d" % [Globals.current_health, Globals.max_health]
	$ShieldHealth/Health/Label.text = str(Globals.current_health)

func player_won_the_fight():
	yield(get_tree().create_timer(1.0), "timeout")
	for card in $PlayerCards.get_children():
		card.float_card_down_and_destroy()
	for enemy in $Enemies.get_children():
		enemy.float_card_up_and_destroy()
	yield(get_tree().create_timer(0.25), "timeout")
	$CardReward.spawn_rewards()

func enemy_queued_for_death(enemy):
	enemy_count -= 1
	if enemy_count == 0:
		$TopBar/EndTurnButton.hide()
		player_won_the_fight()

func deal_player_hand():
	for i in range(0, INITIAL_HAND_SIZE):
		if current_deck.empty() and current_discard.empty():
			update_ui()
			break
		elif current_deck.empty():
			var discard_copy = current_discard.duplicate()
			discard_copy.shuffle()
			current_deck = discard_copy
			current_discard.clear()
			update_ui()
			yield(get_tree().create_timer(CARD_DEAL_TIME_OFFSET), "timeout")
		update_ui()
		if i > 0:
			yield(get_tree().create_timer(CARD_DEAL_TIME_OFFSET), "timeout")
		play_deal_card_sound(i)
		var next_card = current_deck.pop_front()
		current_hand.push_back(next_card)
		var next_card_obj = Card.instance()
		$PlayerCards.add_child(next_card_obj)
		next_card_obj.set_card(next_card)
		var extra_space_at_end = (get_viewport_rect().size.x / INITIAL_HAND_SIZE) - CARD_WIDTH
		next_card_obj.spawn_in_from_x_pos(3 + (extra_space_at_end / 2.0) + ((get_viewport_rect().size.x - 8) / INITIAL_HAND_SIZE) * i)
		update_ui()
	yield(get_tree().create_timer(CARD_DEAL_TIME_OFFSET * 2), "timeout")
	if enemy_count > 0:
		$TopBar/EndTurnButton.show()

func play_deal_card_sound(card_index):
	yield(get_tree().create_timer(0.25), "timeout")
	$DealCard.pitch_scale = 1.0 + (card_index / 25.0)
	$DealCard.play()

func discard_card(card):
	current_discard.push_back(card)
	update_ui()

func add_card(card):
	current_deck.push_back(card)
	update_ui()

func _on_EndTurnButton_pressed():
	$EndTurn.play()
	$TopBar/EndTurnButton.hide()
	get_tree().call_group("Terminal", "clear_terminal_text")
	for card in $PlayerCards.get_children():
		card.hide_for_enemy_turn()
	var total_shield = get_total_player_shield()
	$ShieldHealth/Shield/Label.text = str(total_shield)
	$ShieldHealth/Health/Label.text = str(Globals.current_health)
	yield(get_tree().create_timer(0.1), "timeout")
	$Tween.interpolate_property($ShieldHealth, "rect_position", $ShieldHealthStart.position, $ShieldHealthEnd.position, 0.75, Tween.TRANS_QUART, Tween.EASE_IN_OUT)
	var player_offset = Vector2(6, 25)
	$Tween.interpolate_property($Player, "position", $ShieldHealthStart.position + player_offset, $ShieldHealthEnd.position + player_offset, 0.75, Tween.TRANS_QUART, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	yield(get_tree().create_timer(0.45), "timeout")
	for enemy in $Enemies.get_children():
		if enemy.health > 0:
			enemy.attack_player()
	yield(get_tree().create_timer(0.15), "timeout")
	var enemy_damage = get_total_enemy_damage()
	if enemy_damage <= total_shield:
		$BlockShield.play()
		total_shield -= enemy_damage
		$ShieldHealth/Shield/Label.text = str(total_shield)
		yield(get_tree().create_timer(0.55), "timeout")
	else:
		$ShieldHealth/Shield/Label.text = str(0)
		enemy_damage -= total_shield
		Globals.current_health = max(0, Globals.current_health - enemy_damage)
		update_ui()
		if Globals.current_health == 0:
			$Die.play()
		else:
			$TakeDamage.play()
		yield(get_tree().create_timer(0.85), "timeout")
	if Globals.current_health == 0:
		$PlayerAnimation.stop()
		yield(get_tree().create_timer(0.5), "timeout")
		$PlayerAnimation.play("death")
		yield($PlayerAnimation, "animation_finished")
		$GameOver.show()
		$TopBar/ContinueButton.text = "MAINMENU"
		$TopBar/ContinueButton.show()
	else:
		$Tween.interpolate_property($ShieldHealth, "rect_position", $ShieldHealth.rect_position, $ShieldHealthStart.position, 0.75, Tween.TRANS_QUART, Tween.EASE_IN_OUT)
		$Tween.interpolate_property($Player, "position", $Player.position, $ShieldHealthStart.position, 0.75, Tween.TRANS_QUART, Tween.EASE_IN_OUT)
		$Tween.start()
		yield(get_tree().create_timer(0.1), "timeout")
		deal_player_hand()

func get_total_enemy_damage():
	var total_damage = 0
	for enemy in $Enemies.get_children():
		if enemy.health > 0:
			total_damage += enemy.damage
	return total_damage

func get_total_player_shield():
	var total_shield = 0
	for card in $PlayerCards.get_children():
		if !card.is_queued_for_deletion:
			total_shield += card.card.shield
	return total_shield

func _on_Health_mouse_entered():
	get_tree().call_group("Terminal", "set_terminal_text", "HP: Your current health", HeartTexture)

func _on_Icon_mouse_exited():
	get_tree().call_group("Terminal", "clear_terminal_text")

func _on_EndTurnButton_mouse_entered():
	var shield = get_total_player_shield()
	get_tree().call_group("Terminal", "set_terminal_text", "End turn with +%d shield" % shield)

func _on_ContinueButton_pressed():
	if $GameOver.visible:
		TransitionScreen.transition_to(Globals.MainMenu)
	else:
		TransitionScreen.transition_to(Globals.Map)

func _on_Enemies_child_exiting_tree(node):
	if $Enemies.get_child_count() == 1:
		pass

func _on_Deck_mouse_entered():
	$TopBar/HBox/Deck/Icon._on_Icon_mouse_entered()

func _on_Discard_mouse_entered():
	$TopBar/HBox/Discard/Icon._on_Icon_mouse_entered()
