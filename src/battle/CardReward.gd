extends Control

const RewardCard = preload("res://src/cards/RewardCard.tscn")

var CARD_WIDTH = 35
var shown_choose_card = false

export(int) var card_count = 3
export(Array, Resource) var possible_cards = []

func _ready():
	$ChooseHint.hide()

func spawn_rewards():
	$ChooseHint.show()
	get_tree().call_group("Terminal", "set_terminal_text", "Choose a card")
	randomize()
	possible_cards.shuffle()
	for i in range(0, card_count):
		var next_card = RewardCard.instance()
		next_card.set_card(possible_cards[randi() % len(possible_cards)])
		add_child(next_card)
		next_card.spawn_in_from_x_pos(get_node("%dCardPositions" % [card_count]).get_child(i).rect_global_position.x - (CARD_WIDTH / 2.0))
	yield(get_tree().create_timer(0.5), "timeout")

func card_reward_chosen(chosen_reward):
	for child in get_children():
		if "RewardCard" in child.name and child != chosen_reward:
			child.set_unchosen()

func _on_ChooseHint_mouse_entered():
	if !shown_choose_card:
		shown_choose_card = true
		get_tree().call_group("Terminal", "set_terminal_text", "Choose a card")

func _on_ChooseHint_mouse_exited():
	get_tree().call_group("Terminal", "clear_terminal_text")
