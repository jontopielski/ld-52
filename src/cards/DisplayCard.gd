extends Button

export(Resource) var card = null setget set_card
export(float) var tween_time = 0.25
export(Vector2) var move_offset = Vector2(0, 5)

var resting_position = Vector2.ZERO
var target_rect_position = Vector2.ZERO
var preview_card = null
var child_index = -1
var spawned_in = false

func set_card(_card):
	card = _card
	$BaseCard/Title.text = card.name
	$BaseCard/CardStats.set_card(card)
	if Globals.show_debug_values:
		$BaseCard/Weight.show()
		$BaseCard/Weight.text = str(Sort.get_card_weight(card))

func spawn_in_from_x_position(starting_x, index, total_cards):
	randomize()
	var tween_time = ((0.3 / total_cards) * index) + .5
	rect_position = Vector2(starting_x, 48)
	$Tween.interpolate_property(self, "rect_position", rect_position, Vector2(rect_position.x, 0), tween_time, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()

func set_text_centered():
	$BaseCard/Title.align = Label.ALIGN_CENTER

func set_clickable():
	disabled = false
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func remove_card(map_card_ref):
	if map_card_ref == self:
		queue_free()

func set_unclickable():
	disabled = true
	mouse_default_cursor_shape = Control.CURSOR_ARROW

func _on_DisplayCard_mouse_entered():
	if !spawned_in:
		return
	$Tween.stop_all()
	$Tween.interpolate_property($BaseCard, "rect_position", $BaseCard.rect_position, resting_position - move_offset, tween_time, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()
	get_tree().call_group("CardDisplay", "show_child_at_index", child_index)

func _on_DisplayCard_mouse_exited():
	if !spawned_in:
		return
	$Tween.stop_all()
	$Tween.interpolate_property($BaseCard, "rect_position", $BaseCard.rect_position, resting_position, tween_time, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()

func _on_DisplayCard_pressed():
	get_tree().call_group("map_card_listeners", "card_selected", self)

func _on_Tween_tween_completed(object, key):
	if key == ":rect_position" and !spawned_in:
		spawned_in = true
