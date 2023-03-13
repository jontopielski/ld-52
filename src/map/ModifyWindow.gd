tool
extends PanelContainer

signal modification_finished

const RewardWindowPost = preload("res://src/battle/RewardWindowPost.tres")
const BeforeIcon = preload("res://resources/icons/Before.tres")
const DirectionIcon = preload("res://resources/icons/Direction.tres")
const AfterIcon = preload("res://resources/icons/After.tres")
const RemoveIcon = preload("res://resources/icons/Remove.tres")
const FusionDirectionIcon = preload("res://resources/icons/FusionDirection.tres")
const SacrificeIcon = preload("res://resources/icons/Sacrifice.tres")
const RecipientIcon = preload("res://resources/icons/Recipient.tres")
const Damage = preload("res://resources/icons/Damage.tres")
const Shield = preload("res://resources/icons/Shield.tres")
const SkullAnimation = preload("res://src/effects/SkullAnimation.tscn")

export(String) var title = "Modify Event" setget set_title
export(Enums.ModifyType) var modify_type = Enums.ModifyType.NONE setget set_modify_type
export(bool) var use_transitions = false

onready var preview_card = find_node("PreviewCard")
onready var left_card = find_node("LeftCard")
onready var right_card = find_node("RightCard")

var current_card = null
var fusion_card = null
var imbue_effect = null

func render_card_display(modify_type):
	$Content/Cards/HBox/LeftCard/Icon.set_icon(BeforeIcon)
	$Content/Cards/HBox/RelationIcon.set_icon(DirectionIcon)
	$Content/Cards/HBox/RightCard/Icon.set_icon(AfterIcon)
	$Content/Cards/HBox/RelationIcon.show()
	$Content/Cards/HBox/RightCard.show()
	$Extra.hide()
	match modify_type:
		Enums.ModifyType.REMOVE:
			$Content/Cards/HBox/RelationIcon.hide()
			$Content/Cards/HBox/RightCard.hide()
			$Content/Cards/HBox/LeftCard/Icon.set_icon(RemoveIcon)
		Enums.ModifyType.IMBUE:
			$Extra.show()
		Enums.ModifyType.FUSION:
			$Extra.show()
			$Extra/Icon.set_icon(SacrificeIcon)
			$Content/Cards/HBox/LeftCard/Icon.set_icon(RecipientIcon)
			$Content/Cards/HBox/RelationIcon.set_icon(FusionDirectionIcon)
			$Content/Cards/HBox/RightCard/Icon.set_icon(SacrificeIcon)

func _ready():
	hide_action_buttons()
	if modify_type == Enums.ModifyType.IMBUE:
		imbue_effect = Globals.get_next_positive_effect()
		$Extra/Icon.set_icon(imbue_effect)

func handle_returning_card_to_hand(card_obj):
	card_obj.tween_to_hand_position()
	if card_obj == current_card:
		current_card = null
	elif card_obj == fusion_card:
		fusion_card = null
	hide_action_buttons()

func card_selected(card_obj):
	if card_obj.is_in_modify_position:
		AudioManager.play_sound("CardCanceled")
		handle_returning_card_to_hand(card_obj)
		return
	AudioManager.play_sound("CardSelected")
	if modify_type == Enums.ModifyType.FUSION:
		fusion_card_selected(card_obj)
		if current_card and fusion_card:
			update_preview_card(current_card.card)
		return
	if current_card:
		preview_card.hide()
		current_card.tween_to_hand_position()
	card_obj.set_modified()
	card_obj.tween_to_position(left_card.rect_global_position)
	current_card = card_obj
	show_action_buttons()
	update_preview_card(current_card.card)

func tween_to_modify_position_finished(card_obj):
	if should_show_preview_card():
		preview_card.show()

func fusion_card_selected(card_obj):
	if !current_card:
		card_obj.set_modified()
		card_obj.tween_to_position(left_card.rect_global_position)
		current_card = card_obj
	elif !fusion_card:
		card_obj.set_modified()
		card_obj.tween_to_position(right_card.rect_global_position)
		fusion_card = card_obj
	elif current_card and fusion_card:
		fusion_card.tween_to_hand_position()
		card_obj.set_modified()
		card_obj.tween_to_position(right_card.rect_global_position)
		fusion_card = card_obj
	if current_card and fusion_card:
		show_action_buttons()

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
		Enums.ModifyType.FUSION:
			var possible_stats = get_all_stats_from_card(fusion_card.card)
			randomize(); possible_stats.shuffle()
			var next_stat = possible_stats.front()
			match next_stat:
				Damage:
					after_card.damage += 1
				Shield:
					after_card.shield += 1
				_:
					after_card.effects.push_back(next_stat)
	return after_card

func get_all_stats_from_card(card):
	var stats = []
	for damage in range(0, card.damage):
		stats.push_back(Damage)
	for shield in range(0, card.shield):
		stats.push_back(Shield)
	for effect in card.effects:
		stats.push_back(effect)
	return stats

func modify_card():
	handle_sfx()
	preview_card.hide()
	get_tree().call_group("map_cards", "set_unclickable")
	disable_action_buttons()
	if modify_type == Enums.ModifyType.REMOVE:
		current_card.finish_remove()
		yield(get_tree().create_timer(0.5), "timeout")
		get_tree().call_group("CardDisplay", "align_cards")
		send_finished_signal()
		return
	elif modify_type == Enums.ModifyType.FUSION:
		spawn_skull_animation_at_pos($Content/Cards/HBox/RightCard/Icon.rect_global_position)
		Globals.remove_card(fusion_card.card)
		fusion_card.queue_free()
	current_card.finish_modification(preview_card.card)
	yield(current_card.get_node("AnimationPlayer"), "animation_finished")
	preview_card.queue_free()
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().call_group("CardDisplay", "align_cards")
	current_card.tween_to_hand_position()
	send_finished_signal()

func handle_sfx():
	match modify_type:
		Enums.ModifyType.SWAP:
			AudioManager.play_sound("CardSwapped")
		Enums.ModifyType.UPGRADE:
			AudioManager.play_sound("CardUpgraded")
		Enums.ModifyType.REMOVE:
			pass
		Enums.ModifyType.FUSION:
			AudioManager.play_sound("CardFused")
		Enums.ModifyType.IMBUE:
			AudioManager.play_sound("CardImbued")

func send_finished_signal():
	var is_part_of_random_event = !get_parent().name == "Events"
	get_tree().call_group("Terminal", "clear_terminal_text")
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
	if !use_transitions:
		add_stylebox_override("panel", RewardWindowPost)
		yield(get_tree().create_timer(0.25), "timeout")
		get_tree().call_group("map_cards", "set_clickable")
		return
	AudioManager.play_sound("WindowOpened")
	rect_pivot_offset = Globals.current_map_node_rect_position - rect_position + Vector2(4, 4)
	$Cover.show()
	$Content.hide()
	var tween_time = 0.4
	rect_scale = Vector2.ZERO
	$Tween.interpolate_property(self, "rect_scale", Vector2.ZERO, Vector2.ONE, tween_time, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	add_stylebox_override("panel", RewardWindowPost)
	$Content.show()
	$Cover.hide()
	get_tree().call_group("map_cards", "set_clickable")

func spawn_out():
	if !use_transitions or true:
		if modify_type == Enums.ModifyType.REMOVE:
			yield(get_tree().create_timer(0.6), "timeout")
		else:
			yield(get_tree().create_timer(0.2), "timeout")
		queue_free()
		return
	rect_pivot_offset = Globals.current_map_node_rect_position - rect_position + Vector2(4, 4)
	$Cover.show()
	$Content.hide()
	var tween_time = 0.4
	$Tween.interpolate_property(self, "rect_scale", Vector2.ONE, Vector2.ZERO, tween_time, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	queue_free()

func should_show_preview_card():
	if modify_type == Enums.ModifyType.REMOVE:
		return false
	if modify_type == Enums.ModifyType.FUSION:
		return false
	return true

func spawn_skull_animation_at_pos(pos):
	var next_skull = SkullAnimation.instance()
	get_parent().get_parent().add_child(next_skull)
	next_skull.global_position = pos + Vector2(4, 2)

func _on_Undo_pressed():
	AudioManager.play_sound("CardCanceled")
	if current_card:
		preview_card.hide()
		hide_action_buttons()
		current_card.tween_to_hand_position()
		current_card = null
	if fusion_card:
		fusion_card.tween_to_hand_position()
		fusion_card = null

func _on_Confirm_pressed():
	modify_card()
