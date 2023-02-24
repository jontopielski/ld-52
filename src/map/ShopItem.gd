extends Button

const Icon = preload("res://src/cards/Icon.tscn")
const Damage = preload("res://resources/icons/Damage.tres")
const Shield = preload("res://resources/icons/Shield.tres")
const Location = preload("res://resources/icons/Location.tres")
const Reroll = preload("res://resources/icons/Reroll.tres")

export(Resource) var resource = null setget set_resource

var item_type = Enums.ItemType.NONE

func set_resource(_resource):
	resource = _resource
	clear_all_symbols()
	if resource == Reroll:
		set_reroll()
	else:
		match resource.resource_path.split("/")[3]:
			"cards":
				item_type = Enums.ItemType.CARD
				set_card_symbols()
			"map_nodes":
				item_type = Enums.ItemType.MAP_NODE
			"relics":
				item_type = Enums.ItemType.RELIC
			"rewards":
				item_type = Enums.ItemType.REWARD
				set_reward_symbols()
		$HBox/Name.text = resource.name

func set_cooldown(cooldown):
	if cooldown > 0:
		$Cooldown/Cooldown.show()
		$Cooldown/Clock.hide()
		$Cooldown/Name.text = str(cooldown)
		set_everything_white()
		disabled = true
		mouse_default_cursor_shape = Control.CURSOR_ARROW

func set_reward_symbols():
	clear_all_symbols()
	var next_icon = Icon.instance()
	next_icon.set_icon(resource.icon)
	$Symbols.add_child(next_icon)
	$Cooldown/Clock.show()
	$Cooldown/Cooldown.hide()
	$Cooldown/Name.text = str(resource.cooldown)

func set_reroll():
	clear_all_symbols()
	item_type = Enums.ItemType.REROLL
	resource = Reroll
	var reroll_icon = Icon.instance()
	reroll_icon.set_icon(Reroll)
	$Symbols.add_child(reroll_icon)
	$HBox/Name.text = "REROLL"

func set_card_symbols():
	add_icon_for_amount(Damage, $Symbols, resource.damage)
	add_icon_for_amount(Shield, $Symbols, resource.shield)
	for effect in resource.effects:
		var next_icon = Icon.instance()
		next_icon.set_icon(effect)
		$Symbols.add_child(next_icon)

func add_icon_for_amount(icon_rsc, cntl_node, amount):
	if amount > 4:
		var next_icon = Icon.instance()
		next_icon.set_icon(icon_rsc)
		cntl_node.add_child(next_icon)
		
		var count_label = $CountLabel.duplicate()
		cntl_node.add_child(count_label)
		count_label.text = str(amount)
		count_label.show()
	else:
		for i in range(0, amount):
			var next_icon = Icon.instance()
			next_icon.set_icon(icon_rsc)
			cntl_node.add_child(next_icon)

func clear_all_symbols():
	for symbol in $Symbols.get_children():
		symbol.queue_free()

func _process(delta):
	if pressed and !get_global_rect().encloses(Rect2(get_global_mouse_position(), Vector2.ZERO)) and $HBox/Name.get_color("font_color") == Color.white:
		set_everything_black()
	elif pressed and get_global_rect().encloses(Rect2(get_global_mouse_position(), Vector2.ZERO)) and $HBox/Name.get_color("font_color") == Color.black:
		set_everything_white()

func _on_ShopItem_mouse_entered():
	if !disabled:
		set_everything_white()

func _on_ShopItem_mouse_exited():
	if !disabled:
		set_everything_black()

func is_mouse_hovering_over_any_icons():
	var is_hovering = false
	for symbol in $Symbols.get_children():
		if symbol.get_global_rect().encloses(Rect2(get_global_mouse_position(), Vector2.ZERO)):
			is_hovering = true
	if $HBox/Cost/Icon.get_global_rect().encloses(Rect2(get_global_mouse_position(), Vector2.ZERO)):
		is_hovering = true
	return is_hovering

func set_everything_white():
	$Cooldown/Name.add_color_override("font_color", Color.white)
	$HBox/Name.add_color_override("font_color", Color.white)
	set_symbols_inverted(true)

func set_everything_black():
	$Cooldown/Name.add_color_override("font_color", Color.black)
	$HBox/Name.add_color_override("font_color", Color.black)
	set_symbols_inverted(false)

func set_symbols_inverted(inverted):
	for symbol in $Symbols.get_children():
		if symbol is TextureRect:
			symbol.inverted = inverted
		elif symbol is Label:
			if inverted:
				symbol.add_color_override("font_color", Color.white)
			else:
				symbol.add_color_override("font_color", Color.black)
	$Cooldown/Cooldown.inverted = inverted
	$Cooldown/Clock.inverted = inverted

func _on_ShopItem_pressed():
	$AnimationPlayer.play("flash")
	match item_type:
		Enums.ItemType.CARD:
			Globals.deck.push_back(resource)
			get_tree().call_group("CardDisplay", "load_cards")
			get_tree().call_group("Map", "update_ui")
			get_tree().call_group("Shop", "item_selected")
		Enums.ItemType.REWARD:
			Globals.reward_to_cooldown_map[resource] = resource.cooldown
			match resource.name:
				"2-Cards", "3-Cards":
					$Selected.play()
					get_tree().call_group("RewardShop", "card_selected")
					get_tree().call_group("Battle", "spawn_card_rewards")
				"Heal":
					$Healed.play()
					Globals.add_health(int(ceil(Globals.max_health / 2)))
				"Boost":
					$Healed.play()
					Globals.max_health += 1
					Globals.add_health(1)
				"Refill":
					$Refill.play()
					for reward in Globals.rewards:
						if reward.name != "Refill":
							Globals.reward_to_cooldown_map[reward] = 0
					get_tree().call_group("RewardShop", "refill_selected")
			for reward in Globals.rewards:
				Globals.reward_to_cooldown_map[reward] = max(0, Globals.reward_to_cooldown_map[reward] - 1)
			get_tree().call_group("ui", "update_ui")
			if !"Cards" in resource.name:
				get_tree().call_group("RewardShop", "item_selected")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "flash":
		yield(get_tree().create_timer(0.25), "timeout")
		disabled = true
