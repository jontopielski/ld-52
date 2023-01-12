extends Control

const MapCard = preload("res://src/cards/MapCard.tscn")
const CARD_WIDTH = 35.0
const STARTING_Y_POSITION = 88

func _ready():
	load_cards()

func load_cards():
	var edge_space = get_edge_space()
	var card_offset_x = (get_viewport_rect().size.x - (edge_space * 2) - CARD_WIDTH) / (len(Globals.deck) - 1)
	var deck_sorted = Globals.deck.duplicate()
	deck_sorted.sort_custom(SortNameAscending, "sort_ascending")
	for i in range(0, len(deck_sorted)):
		var card = deck_sorted[i]
		var next_card = MapCard.instance()
		$Cards.add_child(next_card)
		next_card.set_card(card)
		next_card.rect_position = Vector2(edge_space + (card_offset_x * i), STARTING_Y_POSITION)
		next_card.resting_position = next_card.rect_position

func sort_cards_by_name():
	$ShuffleAlpha.play()
	var cards = []
	for card in $Cards.get_children():
		cards.push_back(card.card)
	cards.sort_custom(SortNameAscending, "sort_ascending")
	for i in range(0, len(cards)):
		$Cards.get_child(i).set_card(cards[i])

func sort_cards_by_damage():
	$ShuffleDamage.play()
	var cards = []
	for card in $Cards.get_children():
		cards.push_back(card.card)
	cards.sort_custom(SortDamageAscending, "sort_ascending")
	for i in range(0, len(cards)):
		$Cards.get_child(i).set_card(cards[i])

func sort_cards_by_gold():
	$ShuffleGold.play()
	var cards = []
	for card in $Cards.get_children():
		cards.push_back(card.card)
	cards.sort_custom(SortGoldDescending, "sort_descending")
	for i in range(0, len(cards)):
		$Cards.get_child(i).set_card(cards[i])

func get_edge_space():
	if len(Globals.deck) <= 5:
		return 10
	elif len(Globals.deck) <= 9:
		return 8
	elif len(Globals.deck) <= 13:
		return 6
	elif len(Globals.deck) <= 17:
		return 4
	else:
		return 2

class SortNameAscending:
	static func sort_ascending(a, b):
		if a.name < b.name:
			return true
		return false

class SortDamageAscending:
	static func sort_ascending(a, b):
		if a.damage > b.damage:
			return true
		return false

class SortGoldDescending:
	static func sort_descending(a, b):
		if a.gold > b.gold:
			return true
		return false
