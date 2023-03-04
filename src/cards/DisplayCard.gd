extends Button

const ShatterCard = preload("res://src/effects/ShatterCard.tscn")

export(Resource) var card = null setget set_card
export(float) var tween_time = 0.25
export(Vector2) var move_offset = Vector2(0, 5)
export(bool) var is_preview_card = false

var resting_position = Vector2.ZERO
var target_rect_position = Vector2.ZERO
var preview_card = null
var child_index = -1
var spawned_in = false
var can_hover = true
var hand_position = Vector2.ZERO
var post_modification_card = null

func _ready():
	if is_preview_card:
		set_unclickable()

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

func finish_modification(card_data):
	post_modification_card = card_data
	$AnimationPlayer.play("flip_360")

func finish_remove():
	Globals.remove_card(card)
	$AnimationPlayer.play("flip_shatter")

func tween_to_hand_position():
	var tween_time = 0.3
	$Tween.interpolate_property(self, "rect_global_position", rect_global_position, hand_position, tween_time, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()
	set_unclickable()

func assign_card_with_next_card():
	var current_card_index = Globals.deck.find(card)
	Globals.deck[current_card_index] = post_modification_card
	set_card(post_modification_card)

func set_text_centered():
	$BaseCard/Title.align = Label.ALIGN_CENTER

func shatter_card():
	var next_shatter = ShatterCard.instance()
	next_shatter.set_back_shatter()
	get_parent().get_parent().add_child(next_shatter)
	next_shatter.global_position = rect_global_position - Vector2(8, 8)
	queue_free()

func set_clickable():
	if is_preview_card:
		return
	disabled = false
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func remove_card(map_card_ref):
	if map_card_ref == self:
		queue_free()

func set_modified():
	hand_position = rect_global_position
	hover_down()
	set_unclickable()
	can_hover = false

func set_unmodified():
	$Tween.stop_all()
	var cancel_tween_time = 0.3
	$Tween.interpolate_property(self, "rect_global_position", rect_global_position, hand_position, cancel_tween_time, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	set_clickable()

func set_unclickable():
	disabled = true
	mouse_default_cursor_shape = Control.CURSOR_ARROW

func _on_DisplayCard_mouse_entered():
	hover_up()

func _on_DisplayCard_mouse_exited():
	hover_down()

func hover_up():
	if !spawned_in or !can_hover:
		return
	$Tween.stop_all()
	$Tween.interpolate_property($BaseCard, "rect_position", $BaseCard.rect_position, resting_position - move_offset, tween_time, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()
	get_tree().call_group("CardDisplay", "show_child_at_index", child_index)

func hover_down():
	if !spawned_in or !can_hover:
		return
	$Tween.stop_all()
	$Tween.interpolate_property($BaseCard, "rect_position", $BaseCard.rect_position, resting_position, tween_time, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()

func _on_DisplayCard_pressed():
	get_tree().call_group("map_card_listeners", "card_selected", self)

func _on_Tween_tween_completed(object, key):
	if key == ":rect_position" and !spawned_in:
		spawned_in = true
	elif key == ":rect_global_position":
		can_hover = true
