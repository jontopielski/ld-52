extends Control

const HeartTexture = preload("res://sprites/symbols/Heart.png")
const Explosion = preload("res://src/effects/Explosion.tscn")
const Card = preload("res://src/cards/Card.tscn")
const Enemy = preload("res://src/cards/Enemy.tscn")

export(int) var base_enemy_spend = 10
export(Resource) var test_enemy_effect = null

var INITIAL_HAND_SIZE = 4
var CARD_WIDTH = 36
var CARD_DEAL_TIME_OFFSET = .2

var current_deck = []
var current_discard = []
var current_hand = []

var enemy_count = 0

func _ready():
	$GameOver.hide()
	$TopBar/ContinueButton.hide()
	$TopBar/EndTurnButton.hide()
	setup_player_deck()
	spawn_enemies()
	deal_player_hand()

func _process(delta):
	if OS.is_debug_build() and Input.is_action_just_pressed("ui_autolose"):
		Globals.current_health = 0
		update_ui()
		_on_EndTurnButton_pressed()
	if OS.is_debug_build() and Input.is_action_just_pressed("ui_autowin"):
		get_tree().call_group("enemies", "die")
	elif OS.is_debug_build() and Input.is_action_just_pressed("ui_jump_to_map"):
		TransitionScreen.transition_to(Globals.Map)

func spawn_explosion_at_pos(pos):
	var next_explosion = Explosion.instance()
	$Explosions.add_child(next_explosion)
	next_explosion.position = pos

func spawn_enemies():
	enemy_count = Globals.get_next_enemy_count()
	while enemy_count == 3 and Globals.current_index <= 1:
		enemy_count = Globals.get_next_enemy_count()
	var enemy_spend = base_enemy_spend + (Globals.current_index * 1.33)
	if Globals.is_facing_boss():
		enemy_spend *= 1.65
	var enemy_weights = get_enemy_weights_array(enemy_count)
	for i in range(0, len(enemy_weights)):
		enemy_weights[i] = enemy_weights[i] * enemy_spend
	$TopBar/Spend.text = "%.2f" % float(enemy_spend)
	var enemy_resources = []
	for i in range(0, enemy_count):
		var next_enemy = EnemyGeneration.generate_enemy(enemy_weights[i], enemy_count, test_enemy_effect)
		enemy_resources.push_back(next_enemy)
		spawn_enemy(next_enemy, i)
	for enemy in $Enemies.get_children():
		enemy.enemies_spawned(enemy_resources)

func get_enemy_weights_array(enemy_count):
	match enemy_count:
		1:
			return [1.0]
		2:
			return Globals.pop_queue("2_enemy_weights").duplicate()
		3:
			return Globals.pop_queue("3_enemy_weights").duplicate()

func spawn_enemy(enemy_resource, enemy_index):
	var next_enemy = Enemy.instance()
	next_enemy.set_enemy(enemy_resource)
	$Enemies.add_child(next_enemy)
	var extra_space_at_end = (get_viewport_rect().size.x / enemy_count) - CARD_WIDTH
	var x_spawn_position = 3 + (extra_space_at_end / 2.0) + ((get_viewport_rect().size.x - 8) / enemy_count) * enemy_index
	next_enemy.spawn_in_from_x_pos(x_spawn_position, 0.1 * enemy_index)

func is_enemy_effect_active(effect):
	for enemy in $Enemies.get_children():
		if enemy.has_effect(effect):
			return true
	return false

func setup_player_deck():
	randomize()
	current_deck = Globals.deck.duplicate(true)
	current_deck.shuffle()

func update_ui():
	$TopBar/Health/Count.text = "%02d/%02d" % [Globals.current_health, Globals.max_health]
	$TopBar/HBox/Deck/Count.text = str(len(current_deck))
	$TopBar/HBox/Discard/Count.text = str(len(current_discard))
	$ShieldHealth/Health/Label.text = str(Globals.current_health)

func player_won_the_fight():
	yield(get_tree().create_timer(1.0), "timeout")
	for card in $PlayerCards.get_children():
		card.float_card_down_and_destroy()
	for enemy in $Enemies.get_children():
		enemy.float_card_up_and_destroy()
	if Globals.has_relic("Regen"):
		Globals.add_health(1)
	yield(get_tree().create_timer(0.25), "timeout")
	$RewardShop.show()
	$RewardShop.spawn_in()

func spawn_card_rewards():
	yield(get_tree().create_timer(0.75), "timeout")
	$RewardShop.hide()
	$CardReward.show()
	$CardReward.spawn_rewards()

func enemy_queued_for_death(enemy):
	enemy_count -= 1
	if enemy_count == 0:
		$TopBar/EndTurnButton.hide()
		player_won_the_fight()

func deal_player_hand():
	var hand_size = INITIAL_HAND_SIZE
	if is_enemy_effect_active("Decrement"):
		hand_size -= 1
	for i in range(0, hand_size):
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
		var next_card = current_deck.pop_front()
		current_hand.push_back(next_card)
		var next_card_obj = Card.instance()
		$PlayerCards.add_child(next_card_obj)
		next_card_obj.set_card(next_card)
		var extra_space_at_end = (get_viewport_rect().size.x / hand_size) - CARD_WIDTH
		var card_delay = CARD_DEAL_TIME_OFFSET * i
		next_card_obj.spawn_in_from_x_pos(3 + (extra_space_at_end / 2.0) + ((get_viewport_rect().size.x - 8) / hand_size) * i, card_delay, i)
		update_ui()
		if is_enemy_effect_active("Decalcify"):
			next_card_obj.turn_fragile()
	yield(get_tree().create_timer(CARD_DEAL_TIME_OFFSET * 2), "timeout")
	if enemy_count > 0:
		$TopBar/EndTurnButton.show()

func discard_card(card):
	current_discard.push_back(card)
	update_ui()

func add_card(card):
	current_deck.push_back(card)
	update_ui()

func is_any_enemy_poisoned():
	for enemy in $Enemies.get_children():
		if enemy.poison > 0:
			return true
	return false

func _on_EndTurnButton_pressed():
	$EndTurn.play()
	$TopBar/EndTurnButton.hide()
	get_tree().call_group("Terminal", "clear_terminal_text")
	if is_any_enemy_poisoned():
		yield(get_tree().create_timer(0.1), "timeout")
		get_tree().call_group("enemies", "take_poison_damage")
		yield(get_tree().create_timer(0.5), "timeout")
		if enemy_count == 0:
			return
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
		if enemy.can_attack():
			enemy.attack_player()
	yield(get_tree().create_timer(0.15), "timeout")
	var enemy_damage = get_total_enemy_damage()
	if enemy_damage <= total_shield:
		if enemy_damage > 0:
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
		$TopBar/ContinueButton.text = "RETURN"
		$TopBar/ContinueButton.show()
	else:
		$Tween.interpolate_property($ShieldHealth, "rect_position", $ShieldHealth.rect_position, $ShieldHealthStart.position, 0.75, Tween.TRANS_QUART, Tween.EASE_IN_OUT)
		$Tween.interpolate_property($Player, "position", $Player.position, $ShieldHealthStart.position, 0.75, Tween.TRANS_QUART, Tween.EASE_IN_OUT)
		$Tween.start()
		get_tree().call_group("enemies", "enemy_turn_ended")
		yield(get_tree().create_timer(0.1), "timeout")
		deal_player_hand()

func get_total_enemy_damage():
	var total_damage = 0
	for enemy in $Enemies.get_children():
		if enemy.can_attack():
			total_damage += enemy.damage
	return total_damage

func get_total_player_shield():
	var total_shield = 0
	for card in $PlayerCards.get_children():
		if !card.is_queued_for_deletion:
			total_shield += card.shield
	if Globals.has_relic("Blubber"):
		total_shield += 1
	if Globals.has_relic("Lid"):
		total_shield = min(3, total_shield)
	return total_shield

func _on_Health_mouse_entered():
	get_tree().call_group("Terminal", "set_terminal_text", "HP: current health", HeartTexture)

func _on_Icon_mouse_exited():
	get_tree().call_group("Terminal", "clear_terminal_text")

func _on_EndTurnButton_mouse_entered():
	var shield = get_total_player_shield()
	get_tree().call_group("Terminal", "set_terminal_text", "End turn with +%d shield" % shield)

func _on_ContinueButton_pressed():
	if $GameOver.visible:
		AudioManager.play_sound("ReturnToMenu")
		TransitionScreen.transition_to(Globals.MainMenu)
	else:
		TransitionScreen.transition_to(Globals.Map)

func _on_Deck_mouse_entered():
	$TopBar/HBox/Deck/Icon._on_Icon_mouse_entered()

func _on_Discard_mouse_entered():
	$TopBar/HBox/Discard/Icon._on_Icon_mouse_entered()
