extends Button

export(Resource) var card = null setget set_card
var move_offset = Vector2(0, 5)
var resting_position = Vector2.ZERO
var preview_card = null

func set_card(_card):
	card = _card
	$BaseCard/Title.text = card.name
	$BaseCard/CardStats.set_card(card)
	if Globals.show_debug_values:
		$BaseCard/Weight.show()
		$BaseCard/Weight.text = str(Sort.get_card_weight(card))

func spawn_in_from_x_pos(x_pos):
	rect_position = Vector2(x_pos, $SpawnStartYPosition.position.y)
	$AnimationPlayer.play("flip_spawn")
	var TWEEN_TIME = rand_range(.45, .55)
	$Tween.interpolate_property(self, "rect_position", rect_position, Vector2(rect_position.x, $SpawnEndYPosition.position.y), TWEEN_TIME, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	mouse_filter = Control.MOUSE_FILTER_STOP
	resting_position = rect_position

func _on_MapCard_mouse_entered():
	if !$BaseCard/CardStats.is_mouse_hovering_over_any_icons():
		get_tree().call_group("Terminal", "set_terminal_text", "Add card to your deck")
	$Tween.stop_all()
	$Tween.interpolate_property(self, "rect_position", rect_position, resting_position - move_offset, .25, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()

func _on_MapCard_mouse_exited():
	if !$BaseCard/CardStats.is_mouse_hovering_over_any_icons():
		get_tree().call_group("Terminal", "clear_terminal_text")
	$Tween.stop_all()
	$Tween.interpolate_property(self, "rect_position", rect_position, resting_position, .25, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()

func set_unchosen():
	$AnimationPlayer.play("flip")
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	mouse_default_cursor_shape = Control.CURSOR_ARROW
	yield(get_tree().create_timer(0.25), "timeout")
	var TWEEN_TIME = .75
	$Tween.interpolate_property(self, "rect_position", rect_position, Vector2(rect_position.x, $CardUnchosenPosition.position.y), TWEEN_TIME, Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_all_completed")

func _on_Tween_tween_completed(object, key):
	if rect_position == resting_position - move_offset:
		pass

func _on_RewardCard_pressed():
	$CardChosen.play()
	Globals.deck.push_back(card)
	get_tree().call_group("Battle", "add_card", card)
	get_tree().call_group("Terminal", "clear_terminal_text")
	$AnimationPlayer.play("flip")
	get_parent().card_reward_chosen(self)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	mouse_default_cursor_shape = Control.CURSOR_ARROW
	yield(get_tree().create_timer(0.25), "timeout")
	var TWEEN_TIME = .75
	$Tween.interpolate_property(self, "rect_position", rect_position, Vector2(rect_position.x, $CardChosenPosition.position.y), TWEEN_TIME, Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
	$Tween.start()
	yield(get_tree().create_timer(0.5), "timeout")
	TransitionScreen.transition_to(Globals.Map)
