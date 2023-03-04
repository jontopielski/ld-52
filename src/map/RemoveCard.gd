extends Control

var card_to_remove = null

func _ready():
	if get_tree().current_scene.name == name:
		add_child(load("res://src/cards/CardDisplay.tscn").instance())
		yield(get_tree().create_timer(0.05), "timeout")
	$Window/Actions.hide()
	$Window/Instructions.show()
	get_tree().call_group("map_cards", "set_clickable")

func card_selected(card_obj):
	AudioManager.play_sound("CardSelected")
	card_to_remove = card_obj.card
	var selected_card = card_obj.get_node("BaseCard").duplicate(DUPLICATE_USE_INSTANCING)
	$SelectedCard.add_child(selected_card)
	selected_card.get_node("CardStats").set_card(card_obj.card)
	selected_card.rect_global_position = card_obj.rect_global_position
	var tween_time = 0.2
	$Tween.interpolate_property(selected_card, "rect_position", selected_card.rect_position, Vector2.ZERO, tween_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	$Window/Instructions.hide()
	$Window/Actions.show()
	get_tree().call_group("map_cards", "remove_card", card_obj)
	get_tree().call_group("map_cards", "set_unclickable")

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
	card_to_remove = null
	get_tree().call_group("CardDisplay", "load_cards")
	$SelectedCard.get_child(0).queue_free()
	$Window/Instructions.show()
	$Window/Actions.hide()
	_on_Confirm_mouse_exited()
	_on_Cancel_mouse_exited()
	yield(get_tree().create_timer(0.05), "timeout")
	get_tree().call_group("map_cards", "set_clickable")

func _on_Confirm_pressed():
	AudioManager.play_sound("CardRemoved")
	Globals.remove_card(card_to_remove)
	get_tree().call_group("Map", "event_finished")
	$SelectedCard.get_child(0).queue_free()
	queue_free()
