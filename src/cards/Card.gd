extends Button

export(Resource) var card = null setget set_card

var PLACEMENT_OFFSET = Vector2(0, 9)

var mouse_offset = Vector2.ZERO
var held = false
var is_hovering_enemy = false
var hovered_enemy_ref = null
var position_before_hold = Vector2.ZERO
var is_queued_for_deletion = false

func set_card(_card):
	card = _card
	if card and has_node("BaseCard/CardStats"):
		$BaseCard/Title.text = card.name
		$BaseCard/CardStats.set_card(card)

func spawn_in_from_x_pos(x_pos):
	$BaseCard/CardStats.set_card(card)
	rect_position = Vector2(x_pos, $SpawnStartYPosition.position.y)
	$AnimationPlayer.play("flip_spawn")
	var TWEEN_TIME = .35
	$Tween.interpolate_property(self, "rect_position", rect_position, Vector2(rect_position.x, $SpawnEndYPosition.position.y), TWEEN_TIME, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()

func get_enemies_from_colliding_areas(areas):
	var enemies = []
	for area in areas:
		if "Enemy" in area.name:
			enemies.push_back(area.get_parent())
	return enemies

func _process(delta):
	var colliding_enemies = get_enemies_from_colliding_areas($CardArea.get_overlapping_areas())
	if !is_hovering_enemy:
		if !colliding_enemies.empty():
			is_hovering_enemy = true
			hovered_enemy_ref = colliding_enemies.front()
	elif is_hovering_enemy:
		if colliding_enemies.empty():
			hovered_enemy_ref = null
			is_hovering_enemy = false
		elif len(colliding_enemies) == 1 and hovered_enemy_ref != colliding_enemies.front():
			hovered_enemy_ref = colliding_enemies.front()
	if pressed:
		if is_hovering_enemy and hovered_enemy_ref.health > 0 and Rect2(hovered_enemy_ref.rect_position, hovered_enemy_ref.rect_size + Vector2(0, 4)).grow(4).encloses(Rect2(get_global_mouse_position(), Vector2.ZERO)):
			rect_global_position = hovered_enemy_ref.rect_position + PLACEMENT_OFFSET
		else:
			rect_global_position = get_global_mouse_position() + mouse_offset
			var viewport_rect = get_viewport_rect()
			rect_global_position.x = clamp(rect_global_position.x, 0, viewport_rect.size.x - 35.0)
			rect_global_position.y = clamp(rect_global_position.y, 9.0, viewport_rect.size.y - 53.0)

func hide_for_enemy_turn():
	if is_queued_for_deletion:
		return
	get_tree().call_group("Battle", "discard_card", card)
	$AnimationPlayer.play("flip")
	var target_position = Vector2(rect_position.x, $SpawnStartYPosition.position.y)
	var TWEEN_TIME = 1.0
	$Tween.interpolate_property(self, "rect_position", rect_position, target_position, TWEEN_TIME, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	queue_free()

func _on_Card_button_down():
	position_before_hold = rect_position
	get_parent().move_child(self, get_parent().get_child_count())
	mouse_offset = rect_global_position - get_global_mouse_position()

func _on_Card_button_up():
	if is_hovering_enemy and rect_global_position == hovered_enemy_ref.rect_position + PLACEMENT_OFFSET:
		if card.damage > 0 and hovered_enemy_ref.health > 0:
			hovered_enemy_ref.reduce_health(card.damage)
			$AnimationPlayer.play("flip_discard")
			float_card_up_and_destroy()
		else:
			$Error.play()
			yield(get_tree().create_timer(0.05), "timeout")
			var TWEEN_TIME = rect_position.distance_to(position_before_hold) / 200.0
			TWEEN_TIME = 0.3
			$Tween.interpolate_property(self, "rect_position", rect_position, position_before_hold, TWEEN_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$Tween.start()

func float_card_up_and_destroy():
	get_tree().call_group("Battle", "discard_card", card)
	is_queued_for_deletion = true
	var TWEEN_TIME = .4
	$Tween.interpolate_property(self, "rect_position", rect_position, Vector2(rect_position.x, $DiscardEndYPosition.position.y), TWEEN_TIME, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	queue_free()

func float_card_down_and_destroy():
	is_queued_for_deletion = true
	var TWEEN_TIME = rand_range(.35, .5)
	$Tween.interpolate_property(self, "rect_position", rect_position, Vector2(rect_position.x, $SpawnStartYPosition.position.y), TWEEN_TIME, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	queue_free()

func _on_Card_pressed():
	held = !held

func _on_Title_mouse_entered():
	return
	get_tree().call_group("terminals", "set_terminal_text", card.name + ": " + card.description)

func _on_Title_mouse_exited():
	return
	get_tree().call_group("terminals", "clear_terminal_text")

func _on_Tween_tween_all_completed():
	mouse_filter = Control.MOUSE_FILTER_STOP

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "flip_spawn":
		pass
