extends Node

func sort_cards_by_weight(cards):
	cards.sort_custom(SortCardWeightAscending, "sort_ascending")

func get_card_weight(card):
	return SortCardWeightAscending.get_card_weight(card)

func get_average_card_weight(cards):
	var total_weight = 0.0
	for card in cards:
		total_weight += get_card_weight(card)
	return total_weight / len(cards)

func get_enemy_weight(enemy):
	var total_weight = 0.0
	total_weight += factorial(0.45, enemy.damage)
	total_weight += factorial(0.35, enemy.health)
	for effect in enemy.effects:
		total_weight *= effect.multiplier
	return total_weight

func factorial(base, amount):
	var total = 0.0
	for i in range(1, amount+1):
		total += base * i
	return total

class SortCardWeightAscending:
	static func sort_ascending(a, b):
		if get_card_weight(a) < get_card_weight(b):
			return true
		return false
	static func get_card_weight(card):
		var total_weight = 0.0
		total_weight += factorial(1.0, card.damage)
		var shield_weight = factorial(.75, card.shield)
		if card.damage > 0:
			total_weight += shield_weight * min(1.0, (float(card.shield) / float(card.damage)))
		else:
			total_weight += shield_weight
		for effect in card.effects:
			total_weight *= effect.multiplier
		return total_weight
	static func factorial(base, amount):
		var total = 0.0
		for i in range(1, amount+1):
			total += base * i
		return total
