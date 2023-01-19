extends VBoxContainer

const Icon = preload("res://src/cards/Icon.tscn")
const Damage = preload("res://resources/icons/Damage.tres")
const Shield = preload("res://resources/icons/Shield.tres")
const Gold = preload("res://resources/icons/Gold.tres")

export(Resource) var card = null setget set_card
export(bool) var is_using_manual_mouse_entered = false setget set_is_using_manual_mouse_entered

func set_card(_card):
	card = _card
	if !Engine.editor_hint and has_node("Damage"):
		render_current_card()

func set_is_using_manual_mouse_entered(_is_using_manual_mouse_entered):
	is_using_manual_mouse_entered = _is_using_manual_mouse_entered

func is_mouse_hovering_over_any_icons():
	var is_hovering = false
	for list in get_children():
		for icon in list.get_children():
			if icon.get_global_rect().encloses(Rect2(get_global_mouse_position(), Vector2.ZERO)):
				is_hovering = true
	return is_hovering

func render_current_card():
	clear_existing_icons()
	add_icon_for_amount(Damage, $Damage, card.damage)
	add_icon_for_amount(Shield, $Shield, card.shield)
	add_icon_for_amount(Gold, $Gold, card.gold)
	add_effects_icons()

func add_effects_icons():
	for effect in card.effects:
		var next_icon = Icon.instance()
		next_icon.set_icon(effect)
		$Effects.add_child(next_icon)
		next_icon.set_is_using_manual_mouse_entered(is_using_manual_mouse_entered)

func add_icon_for_amount(icon_rsc, cntl_node, amount):
	if amount > 4:
		var next_icon = Icon.instance()
		next_icon.set_icon(icon_rsc)
		cntl_node.add_child(next_icon)
		next_icon.set_is_using_manual_mouse_entered(is_using_manual_mouse_entered)
		
		var count_label = $CountLabel.duplicate()
		cntl_node.add_child(count_label)
		count_label.text = str(amount)
		count_label.show()
	else:
		for i in range(0, amount):
			var next_icon = Icon.instance()
			next_icon.set_icon(icon_rsc)
			cntl_node.add_child(next_icon)
			next_icon.set_is_using_manual_mouse_entered(is_using_manual_mouse_entered)

func clear_existing_icons():
	for child in $Damage.get_children():
		child.queue_free()
	for child in $Shield.get_children():
		child.queue_free()
	for child in $Gold.get_children():
		child.queue_free()
	for child in $Effects.get_children():
		child.queue_free()
