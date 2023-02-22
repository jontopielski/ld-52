extends Node

const BaseCard = preload("res://resources/cards/BaseCard.tres")

var generated_cards = []

func generate_card(card_weight, is_starting_hand=false):
	var base_card_with_effects = get_base_card_with_effects(is_starting_hand)
	var next_card = generate_stats(base_card_with_effects, card_weight)
	var attempts = 0
	while is_card_duplicate(next_card):
		next_card = generate_stats(base_card_with_effects, card_weight)
		attempts += 1
		if attempts > 3:
			print("Found too many duplicates.. retrying with +5% weight")
			return generate_card(card_weight * 1.025)
	generated_cards.push_back(next_card.duplicate())
	return next_card

func create_card(damage, shield, effects):
	var next_card = BaseCard.duplicate()
	next_card.damage = damage
	next_card.shield = shield
	next_card.effects = effects
	return next_card

func get_base_card_with_effects(is_starting_hand=false):
	var card_effect_type = Globals.get_next_card_effect_type()
	var positive_effect_count = card_effect_type % 10
	var negative_effect_count = card_effect_type / -10 if card_effect_type < 0 else 0
	if is_starting_hand:
		negative_effect_count = 0
	var base_card = BaseCard.duplicate()
	for i in range(0, positive_effect_count):
		var next_effect = Globals.get_next_positive_effect()
		base_card.effects.push_back(next_effect)
		base_card.damage = max(base_card.damage, next_effect.minimum_damage)
		base_card.shield = max(base_card.shield, next_effect.minimum_shield)
	for i in range(0, negative_effect_count):
		var next_effect = Globals.get_next_negative_effect()
		base_card.effects.push_back(next_effect)
		base_card.damage = max(base_card.damage, next_effect.minimum_damage)
		base_card.shield = max(base_card.shield, next_effect.minimum_shield)
	return base_card

func is_card_duplicate(next_card):
	var is_duplicate = false
	for card in generated_cards:
		if card.damage != next_card.damage:
			continue
		if card.shield != next_card.shield:
			continue
		var has_exact_same_effects = true
		for effect in card.effects:
			if !next_card.effects.has(effect):
				has_exact_same_effects = false
		for effect in next_card.effects:
			if !card.effects.has(effect):
				has_exact_same_effects = false
		is_duplicate = has_exact_same_effects
	return is_duplicate

func generate_stats(_card, card_weight):
	var card = _card.duplicate()
	while Sort.get_card_weight(card) < card_weight:
		if randi() % 2 == 0:
			card.damage += 1
		else:
			card.shield += 1
	return card
