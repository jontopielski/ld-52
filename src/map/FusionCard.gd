extends Control

var card_to_upgrade = null

func _ready():
	if get_tree().current_scene.name == name:
		add_child(load("res://src/cards/CardDisplay.tscn").instance())
	$Window/Actions.hide()
	$Window/Instructions.show()
	get_tree().call_group("map_cards", "set_clickable")

func get_selected_card_count():
	if $SelectedCard_01.get_child_count() == 0:
		return 0
	elif $SelectedCard_02.get_child_count() == 0:
		return 1
	else:
		return 2

func card_selected(card_obj):
	AudioManager.play_sound("CardSelected")
	var selected_card = card_obj.get_node("BaseCard").duplicate(DUPLICATE_USE_INSTANCING)
	var selected_card_count = get_selected_card_count()
	if selected_card_count == 0:
		card_to_upgrade = card_obj.card
		$SelectedCard_01.add_child(selected_card)
	else:
		$SelectedCard_02.add_child(selected_card)
	selected_card_count += 1
	selected_card.get_node("CardStats").set_card(card_obj.card)
	selected_card.rect_global_position = card_obj.rect_global_position
	var tween_time = 0.2
	$Tween.interpolate_property(selected_card, "rect_position", selected_card.rect_position, Vector2.ZERO, tween_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	$Window/Instructions.hide()
	$Window/Actions.show()
	if selected_card_count == 1:
		$Window/Actions/Confirm.hide()
	elif selected_card_count == 2:
		$Window/Actions/Confirm.show()
		get_tree().call_group("map_cards", "set_unclickable")
	get_tree().call_group("map_cards", "remove_card", card_obj)

func _on_Cancel_mouse_entered():
	$Window/Actions/Cancel/HBox/Label.add_color_override("font_color", Color.white)
	$Window/Actions/Cancel/Icon.material.set_shader_param("inverted", true)

func _on_Cancel_mouse_exited():
	$Window/Actions/Cancel/HBox/Label.add_color_override("font_color", Color.black)
	$Window/Actions/Cancel/Icon.material.set_shader_param("inverted", false)

func _process(delta):
	if $Window/Actions/Cancel.pressed and !$Window/Actions/Cancel.get_global_rect().encloses(Rect2(get_global_mouse_position(), Vector2.ZERO)) and $Window/Actions/Cancel/Icon.material.get_shader_param("inverted"):
		_on_Cancel_mouse_exited()
	if $Window/Actions/Cancel.pressed and $Window/Actions/Cancel.get_global_rect().encloses(Rect2(get_global_mouse_position(), Vector2.ZERO)) and !$Window/Actions/Cancel/Icon.material.get_shader_param("inverted"):
		_on_Cancel_mouse_entered()
	if $Window/Actions/Confirm.pressed and !$Window/Actions/Confirm.get_global_rect().encloses(Rect2(get_global_mouse_position(), Vector2.ZERO)) and $Window/Actions/Confirm/Icon.material.get_shader_param("inverted"):
		_on_Confirm_mouse_exited()
	if $Window/Actions/Confirm.pressed and $Window/Actions/Confirm.get_global_rect().encloses(Rect2(get_global_mouse_position(), Vector2.ZERO)) and !$Window/Actions/Confirm/Icon.material.get_shader_param("inverted"):
		_on_Confirm_mouse_entered()

func _on_Confirm_mouse_entered():
	$Window/Actions/Confirm/HBox/Label.add_color_override("font_color", Color.white)
	$Window/Actions/Confirm/Icon.material.set_shader_param("inverted", true)

func _on_Confirm_mouse_exited():
	$Window/Actions/Confirm/HBox/Label.add_color_override("font_color", Color.black)
	$Window/Actions/Confirm/Icon.material.set_shader_param("inverted", false)

func _on_Cancel_pressed():
	AudioManager.play_sound("CardCanceled")
	card_to_upgrade = null
	get_tree().call_group("CardDisplay", "load_cards")
	if $SelectedCard_01.get_child_count() > 0:
		$SelectedCard_01.get_child(0).queue_free()
	if $SelectedCard_02.get_child_count() > 0:
		$SelectedCard_02.get_child(0).queue_free()
	$Window/Instructions.show()
	$Window/Actions.hide()
	_on_Confirm_mouse_exited()
	_on_Cancel_mouse_exited()
	yield(get_tree().create_timer(0.05), "timeout")
	get_tree().call_group("map_cards", "set_clickable")

func _on_Confirm_pressed():
	AudioManager.play_sound("CardFusing")
	$Window/Actions.hide()
	$Window/Blanks/BlankCard_01.hide()
	$Window/Blanks/BlankCard_02.hide()
	
	var tween_time = 0.75
	$Tween.interpolate_property($SelectedCard_01, "rect_global_position", $SelectedCard_01.rect_global_position, $FinalCard.rect_global_position, tween_time, Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($SelectedCard_02, "rect_global_position", $SelectedCard_02.rect_global_position, $FinalCard.rect_global_position, tween_time, Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	
	$Window/Blanks/Icon.hide()
	var attributes = $SelectedCard_02.get_child(0).get_node("CardStats").get_icon_array()
	randomize(); attributes.shuffle()
	var fused_card = get_fused_card(card_to_upgrade, attributes)
	var sacrificed_card = $SelectedCard_02.get_child(0).get_node("CardStats").card
	Globals.deck.push_back(fused_card)
	Globals.remove_card(card_to_upgrade)
	Globals.remove_card(sacrificed_card)
	var fused_card_inst = $SelectedCard_01.get_child(0).duplicate(DUPLICATE_USE_INSTANCING)
	$FinalCard.add_child(fused_card_inst)
	$FinalCard.get_child(0).get_node("CardStats").set_card(fused_card)

	yield(get_tree().create_timer(0.35), "timeout")
	$SelectedCard_01.hide()
	$SelectedCard_02.hide()
#	AudioManager.play_sound("CardFused")

	yield(get_tree().create_timer(1.15), "timeout")

	get_tree().call_group("Map", "event_finished")
	queue_free()

func get_fused_card(original_card, icon_array):
	var fused_card = original_card.duplicate()
	var next_attribute = icon_array.front()
	if "Damage" in next_attribute.name:
		fused_card.damage += 1
	elif "Shield" in next_attribute.name:
		fused_card.shield += 1
	else:
		fused_card.effects.push_back(next_attribute)
	return fused_card
