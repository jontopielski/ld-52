extends Button

const CardStats = preload("res://src/cards/CardStats.tscn")
const ShatterCard = preload("res://src/effects/ShatterCard.tscn")
const Frozen = preload("res://resources/enemy_effects/Frozen.tres")
const Fragile = preload("res://resources/effects/negative/Fragile.tres")
const Poisoned = preload("res://resources/enemy_effects/Poisoned.tres")

export(Resource) var card = null setget set_card

var PLACEMENT_OFFSET = Vector2(0, 9)

var damage = 0
var shield = 0
var effects = []

var mouse_offset = Vector2.ZERO
var held = false
var is_hovering_enemy = false
var hovered_enemy_ref = null
var position_before_hold = Vector2.ZERO
var is_queued_for_deletion = false

onready var card_stats = $BaseCard/CardStats

func set_card(_card):
	card = _card
	damage = card.damage
	shield = card.shield
	effects = card.effects.duplicate()
	if has_node("BaseCard"):
		$BaseCard/Title.text = card.name
		calculate_card_stats()
		if Globals.show_debug_values:
			$BaseCard/Title.show()
			$BaseCard/Title.text = str(Sort.get_card_weight(card))

func _ready():
	set_card(card)
	get_tree().call_group("cards", "calculate_card_stats")

func has_effect(effect_name):
	for effect in effects:
		if effect.name == effect_name:
			return true
	return false

func calculate_card_stats():
	damage = get_total_damage()
	card_stats.queue_free()
	card_stats = CardStats.instance()
	$BaseCard.add_child(card_stats)
	card_stats.rect_position = Vector2(2, 10)
	card_stats.render_card_manually(damage, shield, effects)

func get_total_damage():
	var total_damage = card.damage
	if has_effect("Dagger"):
		var dagger_count = 0
		for card in get_tree().get_nodes_in_group("cards"):
			if card != self and card.has_effect("Dagger") and !card.is_queued_for_deletion:
				dagger_count += 1
		total_damage += dagger_count
	return total_damage

func spawn_in_from_x_pos(x_pos, delay=0.0, card_index=0):
	card_stats.set_card(card)
	rect_position = Vector2(x_pos, $SpawnStartYPosition.position.y)
	if delay > 0.0:
		yield(get_tree().create_timer(delay), "timeout")
	play_deal_card_sound(card_index)
	$AnimationPlayer.play("flip_spawn")
	var TWEEN_TIME = .35
	$Tween.interpolate_property(self, "rect_position", rect_position, Vector2(rect_position.x, $SpawnEndYPosition.position.y), TWEEN_TIME, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()

func play_deal_card_sound(card_index):
	yield(get_tree().create_timer(0.25), "timeout")
	$DealCard.pitch_scale = 1.0 + (card_index / 25.0)
	$DealCard.play()

func get_enemies_from_colliding_areas(areas):
	var enemies = []
	for area in areas:
		if "Enemy" in area.name:
			enemies.push_back(area.get_parent())
	return enemies

func turn_fragile():
	if !has_effect("Fragile"):
		effects.push_back(Fragile)
	calculate_card_stats()

func _process(delta):
	var colliding_enemies = get_enemies_from_colliding_areas($CardArea.get_overlapping_areas())
	if !is_hovering_enemy:
		if !colliding_enemies.empty():
			is_hovering_enemy = true
			hovered_enemy_ref = colliding_enemies.front()
	elif is_hovering_enemy:
		if colliding_enemies.empty():
			hovered_enemy_ref = null
			is_hovering_enemy = false
		elif len(colliding_enemies) == 1 and hovered_enemy_ref != colliding_enemies.front():
			hovered_enemy_ref = colliding_enemies.front()
	if pressed:
		if is_hovering_enemy and hovered_enemy_ref.health > 0 and Rect2(hovered_enemy_ref.rect_position, hovered_enemy_ref.rect_size + Vector2(0, 4)).grow(4).encloses(Rect2(get_global_mouse_position(), Vector2.ZERO)):
			rect_global_position = hovered_enemy_ref.rect_position + PLACEMENT_OFFSET
		else:
			rect_global_position = get_global_mouse_position() + mouse_offset
			var viewport_rect = get_viewport_rect()
			rect_global_position.x = clamp(rect_global_position.x, 0, viewport_rect.size.x - 35.0)
			rect_global_position.y = clamp(rect_global_position.y, 9.0, viewport_rect.size.y - 53.0)

func hide_for_enemy_turn():
	if is_queued_for_deletion:
		return
	update_card_effects()
	get_tree().call_group("Battle", "discard_card", card)
	$AnimationPlayer.play("flip")
	var target_position = Vector2(rect_position.x, $SpawnStartYPosition.position.y)
	var TWEEN_TIME = 1.0
	$Tween.interpolate_property(self, "rect_position", rect_position, target_position, TWEEN_TIME, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	queue_free()

func update_card_effects():
	if has_effect("Fortify"):
		var new_card = card.duplicate()
		card = new_card
		card.shield += 1

func float_card_up_and_destroy():
	update_card_effects()
	get_tree().call_group("Battle", "discard_card", card)
	is_queued_for_deletion = true
	get_tree().call_group("cards", "calculate_card_stats")
	var TWEEN_TIME = .4
	$Tween.interpolate_property(self, "rect_position", rect_position, Vector2(rect_position.x, $DiscardEndYPosition.position.y), TWEEN_TIME, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	queue_free()

func _on_Card_button_down():
	position_before_hold = rect_position
	get_parent().move_child(self, get_parent().get_child_count())
	mouse_offset = rect_global_position - get_global_mouse_position()

func _on_Card_button_up():
	if is_hovering_enemy and rect_global_position == hovered_enemy_ref.rect_position + PLACEMENT_OFFSET:
		randomize()
		if hovered_enemy_ref.health == 0:
			$Error.play()
			yield(get_tree().create_timer(0.05), "timeout")
			var TWEEN_TIME = rect_position.distance_to(position_before_hold) / 200.0
			TWEEN_TIME = 0.3
			$Tween.interpolate_property(self, "rect_position", rect_position, position_before_hold, TWEEN_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$Tween.start()
			return
		var enemies = [hovered_enemy_ref]
		if has_effect("Multi") or has_effect("Splash"):
			for enemy in get_tree().get_nodes_in_group("enemies"):
				if !enemy in enemies and enemy.health > 0:
					enemies.push_back(enemy)
					if has_effect("Splash"):
						break
		var missed_enemies = []
		for enemy in enemies:
			if has_effect("Imprecise") and randi() % 4 == 0:
				missed_enemies.push_back(enemy)
				continue
			var enemy_health_before_hit = enemy.health
			var damage_to_enemy = damage
			if damage_to_enemy == 0 and Globals.has_relic("Sharpen"):
				damage_to_enemy += 1
			enemy.take_damage(damage_to_enemy)
			if enemy_health_before_hit == enemy.health and damage > 0:
				missed_enemies.push_back(enemy)
		for missed_enemy in missed_enemies:
			enemies.erase(missed_enemy)
		if has_effect("Berserk"):
			var new_card = card.duplicate()
			card = new_card
			card.damage += 1
		if has_effect("Decay"):
			var new_card = card.duplicate()
			card = new_card
			if card.damage > 0:
				card.damage -= 1
		if has_effect("Freeze"):
			for enemy in enemies:
				enemy.add_effect(Frozen)
		if has_effect("Poison"):
			for enemy in enemies:
				var poison_amount = 1
				if Globals.has_relic("Noxious"):
					poison_amount += 1
				enemy.add_poison(poison_amount)
		for card in get_tree().get_nodes_in_group("cards"):
			if card != self and card.has_effect("Stack"):
				card.shield += 1
			if card != self and card.has_effect("Expose") and card.shield > 0:
				card.shield -= 1
		if has_effect("Fragile") and is_able_to_break():
			shatter_card()
		else:
			$AnimationPlayer.play("flip_discard")
			yield($AnimationPlayer, "animation_finished")
			float_card_up_and_destroy()

func is_able_to_break():
	if Globals.has_relic("Sturdy"):
		if randi() % 2 == 0:
			return false
	return true

func shatter_card():
	var next_shatter = ShatterCard.instance()
	next_shatter.global_position = rect_global_position - Vector2(8, 8)
	get_parent().get_parent().get_node("CardEffects").add_child(next_shatter)
	queue_free()

func float_card_down_and_destroy():
	is_queued_for_deletion = true
	get_tree().call_group("cards", "calculate_card_stats")
	var TWEEN_TIME = rand_range(.35, .5)
	$Tween.interpolate_property(self, "rect_position", rect_position, Vector2(rect_position.x, $SpawnStartYPosition.position.y), TWEEN_TIME, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	queue_free()

func _on_Card_pressed():
	held = !held

func _on_Tween_tween_all_completed():
	mouse_filter = Control.MOUSE_FILTER_STOP
