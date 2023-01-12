extends Button

const Icon = preload("res://src/cards/Icon.tscn")
const Damage = preload("res://resources/icons/Damage.tres")
const Shield = preload("res://resources/icons/Shield.tres")
const Gold = preload("res://resources/icons/Gold.tres")

export(Resource) var card = null setget set_card
var preview_card = null

func set_card(_card):
	card = _card
	render_current_card()

func clear_existing_icons():
	for child in $BaseCard/Damage.get_children():
		child.queue_free()
	for child in $BaseCard/Shield.get_children():
		child.queue_free()
	for child in $BaseCard/Gold.get_children():
		child.queue_free()

func render_current_card():
	if !card:
		return
	clear_existing_icons()
	$BaseCard/Title.text = card.name
	add_icon_for_amount(Damage, $BaseCard/Damage, card.damage)
	add_icon_for_amount(Shield, $BaseCard/Shield, card.shield)
	add_icon_for_amount(Gold, $BaseCard/Gold, card.gold)

func add_icon_for_amount(icon_rsc, cntl_node, amount):
	if amount > 4:
		var next_icon = Icon.instance()
		next_icon.set_icon(icon_rsc)
		cntl_node.add_child(next_icon)
		next_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		var count_label = $CountLabel.duplicate()
		cntl_node.add_child(count_label)
		count_label.text = str(amount)
		count_label.show()
	else:
		for i in range(0, amount):
			var next_icon = Icon.instance()
			next_icon.set_icon(icon_rsc)
			cntl_node.add_child(next_icon)
			next_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_MapCard_mouse_entered():
	pass

func _on_MapCard_mouse_exited():
	pass
