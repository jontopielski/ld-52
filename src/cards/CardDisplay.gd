extends Control

const DisplayCard = preload("res://src/cards/DisplayCard.tscn")
const CARD_WIDTH = 35.0

export(bool) var load_every_card = false
export(bool) var randomly_generate_cards = false
export(int) var random_card_count = 10
export(float) var card_weight_increment = 0.25

var is_card_focused = false

func _ready():
	if load_every_card:
		Globals.deck = Globals.get_resources_at_path("res://resources/cards/")
	elif randomly_generate_cards:
		Globals.deck.clear()
		for i in range(1, random_card_count + 1):
			var next_card = CardGeneration.generate_card(i * card_weight_increment)
			Globals.deck.push_back(next_card)
	load_cards()

func _process(delta):
	if is_card_focused:
		var mouse_position = get_global_mouse_position()
		if mouse_position.y <= 80 or mouse_position.y >= 132:
			is_card_focused = false
			reset_card_focuses()

func clear_cards():
	for card in $Cards.get_children():
		card.queue_free()

func reset_card_focuses():
	for card in $Cards.get_children():
		card.show_behind_parent = false

func show_child_at_index(index):
	is_card_focused = true
	for i in range(0, $Cards.get_child_count()):
		if i == index + 1 or i == index + 2 or i == index + 3 or i == index + 4:
			$Cards.get_child(i).show_behind_parent = true
		else:
			$Cards.get_child(i).show_behind_parent = false

func load_cards():
	clear_cards()
	yield(get_tree().create_timer(0.1), "timeout")
	var edge_space = get_edge_space()
	var card_offset_x = (get_viewport_rect().size.x - (edge_space * 2) - CARD_WIDTH) / max(1, (len(Globals.deck) - 1))
	var deck_sorted = Globals.deck.duplicate()
	Sort.sort_cards_by_weight(deck_sorted)
	for i in range(0, len(deck_sorted)):
		var card = deck_sorted[i]
		var next_card = DisplayCard.instance()
		$Cards.add_child(next_card)
		next_card.child_index = i
		if len(deck_sorted) <= 4:
			next_card.set_text_centered()
		next_card.set_card(card)
		next_card.spawn_in_from_x_position(edge_space + (card_offset_x * i), i, len(deck_sorted))

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
