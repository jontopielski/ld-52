tool
extends PanelContainer

signal modification_finished

const RewardWindowPost = preload("res://src/battle/RewardWindowPost.tres")
const BeforeIcon = preload("res://resources/icons/Before.tres")
const DirectionIcon = preload("res://resources/icons/Direction.tres")
const AfterIcon = preload("res://resources/icons/After.tres")
const RemoveIcon = preload("res://resources/icons/Remove.tres")

export(String) var title = "Modify Event" setget set_title
export(Enums.ModifyType) var modify_type = Enums.ModifyType.NONE setget set_modify_type

onready var preview_card = find_node("PreviewCard")

var current_card = null
var imbue_effect = null

func render_card_display(modify_type):
	$Content/Cards/HBox/LeftCard/Icon.set_icon(BeforeIcon)
	$Content/Cards/HBox/RelationIcon.set_icon(DirectionIcon)
	$Content/Cards/HBox/RightCard/Icon.set_icon(AfterIcon)
	match modify_type:
		Enums.ModifyType.REMOVE:
			$Content/Cards/HBox/RelationIcon.hide()
			$Content/Cards/HBox/RightCard.hide()
			$Content/Cards/HBox/LeftCard/Icon.set_icon(RemoveIcon)
		Enums.ModifyType.UPGRADE:
			$Content/Cards/HBox/RelationIcon.show()
			$Content/Cards/HBox/RightCard.show()

func _ready():
	spawn_in()
	hide_action_buttons()
	if modify_type == Enums.ModifyType.IMBUE:
		imbue_effect = Globals.get_next_positive_effect()

func window_spawned_in():
	get_tree().call_group("map_cards", "set_clickable")

func card_selected(card_obj):
	if current_card:
		preview_card.hide()
		current_card.set_unmodified()
	card_obj.set_modified()
	tween_card_to_preview_position(card_obj)
	current_card = card_obj
	show_action_buttons()
	update_preview_card(current_card.card)

func tween_card_to_preview_position(card_obj):
	var tween_time = 0.3
	$Tween.interpolate_property(card_obj, "rect_global_position", card_obj.rect_global_position, $Content/Cards/HBox/LeftCard.rect_global_position, tween_time, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	card_obj.set_unclickable()

func tween_card_back_to_hand_position(card_obj):
	var tween_time = 0.3
	$Tween.interpolate_property(card_obj, "rect_global_position", card_obj.rect_global_position, card_obj.hand_position, tween_time, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()

func update_preview_card(before_card):
	if modify_type == Enums.ModifyType.REMOVE:
		return
	var after_card = get_preview_card(modify_type, before_card)
	preview_card.set_card(after_card)

func get_preview_card(modify_type, before_card):
	var after_card = before_card.duplicate()
	match modify_type:
		Enums.ModifyType.UPGRADE:
			if after_card.damage < after_card.shield:
				after_card.damage += 1
			else:
				after_card.shield += 1
		Enums.ModifyType.SWAP:
			var damage_amount = after_card.damage
			after_card.damage = after_card.shield
			after_card.shield = damage_amount
		Enums.ModifyType.IMBUE:
			if !imbue_effect in after_card.effects:
				after_card.effects.push_back(imbue_effect)
	return after_card

func modify_card():
	get_tree().call_group("map_cards", "set_unclickable")
	disable_action_buttons()
	preview_card.queue_free()
	if modify_type == Enums.ModifyType.REMOVE:
		current_card.finish_remove()
		send_finished_signal()
		return
	current_card.finish_modification(preview_card.card)
	yield(current_card.get_node("AnimationPlayer"), "animation_finished")
	yield(get_tree().create_timer(0.5), "timeout")
	current_card.tween_to_hand_position()
	send_finished_signal()

func send_finished_signal():
	var is_part_of_random_event = !get_parent().name == "Events"
	if is_part_of_random_event:
		emit_signal("modification_finished")
	else:
		get_tree().call_group("Map", "event_finished")

func show_action_buttons():
	$UndoMargin/Undo.show()
	$ConfirmMargin/Confirm.show()

func hide_action_buttons():
	$UndoMargin/Undo.hide()
	$ConfirmMargin/Confirm.hide()
	get_tree().call_group("Terminal", "clear_terminal_text")

func disable_action_buttons():
	$UndoMargin/Undo.disabled = true
	$UndoMargin/Undo.mouse_default_cursor_shape = Control.CURSOR_ARROW
	$ConfirmMargin/Confirm.disabled = true
	$ConfirmMargin/Confirm.mouse_default_cursor_shape = Control.CURSOR_ARROW

func set_modify_type(_modify_type):
	modify_type = _modify_type
	if find_node("PreviewCard"):
		render_card_display(modify_type)

func set_title(_title):
	title = _title
	if has_node("Content/Title"):
		$Content/Title.text = title

func spawn_in():
	rect_pivot_offset = Globals.current_map_node_rect_position - rect_position + Vector2(4, 4)
	$Cover.show()
	$Content.hide()
	var tween_time = 0.4
	rect_scale = Vector2.ZERO
	$Tween.interpolate_property(self, "rect_scale", Vector2.ZERO, Vector2.ONE, tween_time, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()

func spawn_out():
	rect_pivot_offset = Globals.current_map_node_rect_position - rect_position + Vector2(4, 4)
	$Cover.show()
	$Content.hide()
	var tween_time = 0.4
	$Tween.interpolate_property(self, "rect_scale", Vector2.ONE, Vector2.ZERO, tween_time, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	queue_free()

func _on_Tween_tween_completed(object, key):
	if key == ":rect_scale":
		add_stylebox_override("panel", RewardWindowPost)
		$Content.show()
		$Cover.hide()
		window_spawned_in()
	if key == ":rect_global_position" and preview_card:
		if modify_type != Enums.ModifyType.REMOVE:
			preview_card.show()

func _on_Undo_pressed():
	if current_card:
		preview_card.hide()
		hide_action_buttons()
		current_card.set_unmodified()
		current_card = null

func _on_Confirm_pressed():
	modify_card()
