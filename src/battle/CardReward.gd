extends Control

const RewardCard = preload("res://src/cards/RewardCard.tscn")
const CardDisplay = preload("res://src/cards/CardDisplay.tscn")

var CARD_WIDTH = 35
var shown_choose_card = false
var card_display = null

export(int) var card_count = 3
export(Array, Texture) var heart_icons = []

func _ready():
	$HealButton.hide()

func _process(delta):
	if Input.is_action_just_pressed("ui_accept") and get_tree().current_scene.name == "CardReward":
		spawn_rewards()

func spawn_rewards():
	set_card_count()
	get_tree().call_group("Terminal", "set_terminal_text", "Choose a card")
	var card_weight = 2.0 + (0.25 * Globals.current_index)
	var possible_cards = get_generated_cards(card_weight)
	while !is_generated_cards_balanced(possible_cards, .35):
		print("Retrying to generate card rewards..")
		possible_cards = get_generated_cards(card_weight)
	for i in range(0, card_count):
		spawn_reward_card(possible_cards[i], i)
	yield(get_tree().create_timer(0.5), "timeout")
	if !card_display:
		card_display = CardDisplay.instance()
		add_child(card_display)

func set_card_count():
	if Globals.has_reward("2-Cards"):
		card_count = 2
	elif Globals.has_reward("3-Cards"):
		card_count = 3

func is_generated_cards_balanced(cards, closeness_percent):
	Sort.sort_cards_by_weight(cards)
	if is_one_card_objectively_worse(cards):
		return false
	var percent_difference = 1.0 - (Sort.get_card_weight(cards.front()) / Sort.get_card_weight(cards.back()))
	if percent_difference > closeness_percent:
		return false
	else:
		return true

func is_one_card_objectively_worse(cards):
	pass

func get_generated_cards(card_weight):
	var cards = []
	for i in range (0, card_count):
		cards.push_back(CardGeneration.generate_card(card_weight))
	return cards

func spawn_reward_card(card, index):
	var next_card = RewardCard.instance()
	next_card.set_card(card)
	add_child(next_card)
	var x_position = get_node("%dCardPositions" % [card_count]).get_child(index).rect_global_position.x - (CARD_WIDTH / 2.0)
	next_card.spawn_in_from_x_pos(x_position)

func card_reward_chosen(chosen_reward):
	card_display.hide()
	$HealButton.hide()
	for child in get_children():
		if "RewardCard" in child.name and child != chosen_reward:
			child.set_unchosen()
	get_tree().call_group("Battle", "update_ui")

func _on_ChooseHint_mouse_entered():
	if !shown_choose_card:
		shown_choose_card = true
		get_tree().call_group("Terminal", "set_terminal_text", "Choose a card")

func _on_ChooseHint_mouse_exited():
	get_tree().call_group("Terminal", "clear_terminal_text")

func _on_HealButton_mouse_entered():
	get_tree().call_group("Terminal", "set_terminal_text", "Skip card and heal +3 hp")
	$HealButton.icon = heart_icons[1]

func _on_HealButton_mouse_exited():
	get_tree().call_group("Terminal", "clear_terminal_text")
	$HealButton.icon = heart_icons[0]

func _on_HealButton_pressed():
	card_display.hide()
	$HealButton.hide()
	Globals.add_health(3)
	for child in get_children():
		if "RewardCard" in child.name:
			child.set_unchosen()
	get_tree().call_group("Terminal", "clear_terminal_text")
	yield(get_tree().create_timer(0.75), "timeout")
	TransitionScreen.transition_to(Globals.Map)
