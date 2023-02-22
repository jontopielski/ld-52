extends Control

const Phoenix = preload("res://resources/enemies/Phoenix.tres")
const Reborn = preload("res://resources/enemy_effects/Reborn.tres")
const Ashes = preload("res://resources/enemies/Ashes.tres")
const Regen_1 = preload("res://resources/enemy_effects/Regen_1.tres")
const Dodge_1 = preload("res://resources/enemy_effects/Dodge_1.tres")
const Dodge_2 = preload("res://resources/enemy_effects/Dodge_2.tres")
const Poisoned = preload("res://resources/enemy_effects/Poisoned.tres")
const Icon = preload("res://src/cards/Icon.tscn")
const Damage = preload("res://resources/icons/Damage.tres")
const Health = preload("res://resources/icons/Health.tres")
const Card = preload("res://src/cards/Card.tscn")
const SlashAnim = preload("res://sprites/effects/Slash.png")
const PoisonAnim = preload("res://sprites/effects/Poison.png")

export(Resource) var enemy = null setget set_enemy
export(bool) var use_enemy_texture = false

var damage = 0
var health = 0
var effects = []
var poison = 0
var is_queued_for_deletion = false

var attack_player_offset = Vector2(0, 20)

func set_enemy(_enemy):
	enemy = _enemy
	damage = enemy.damage
	health = enemy.health
	effects = enemy.effects.duplicate()
	if Engine.editor_hint:
		render_current_enemy()

func has_effect(effect_name):
	for effect in effects:
		if effect.name == effect_name:
			return true
	return false

func get_effect(effect_name):
	for effect in effects:
		if effect.name == effect_name:
			return effect
	return null

func add_effect(effect):
	effects.push_back(effect)
	render_current_enemy()

func add_poison(poison_amount):
	poison += poison_amount
	render_current_enemy()

func take_poison_damage():
	if poison > 0 and health > 0:
		take_damage(poison, true)
		poison -= 1
		render_current_enemy()

func enemies_spawned(enemies):
	if has_effect("Mob"):
		damage += (len(enemies) - 1)
	render_current_enemy()

func enemy_died(enemy):
	if enemy != self:
		if has_effect("Mob"):
			damage -= 1
	render_current_enemy()

func enemy_spawned():
	pass

func enemy_turn_ended():
	if has_effect("Frozen"):
		remove_effect("Frozen")
	if has_effect("Prebirth"):
		remove_effect("Prebirth")
		add_effect(Reborn)
	if has_effect("Berserk"):
		damage += 1
	if has_effect("Snowball"):
		damage *= 2
	if has_effect("Decalcify"):
		remove_effect("Decalcify")
	if has_effect("Regen") and health > 0:
		var regen_effect = get_effect("Regen")
		if "2" in regen_effect.description:
			health += 2
			remove_effect("Regen")
			add_effect(Regen_1)
		else:
			health += 1
			remove_effect("Regen")
	render_current_enemy()

func can_attack():
	if health <= 0 or damage <= 0:
		return false
	if has_effect("Frozen"):
		return false
	return true

func remove_effect(effect_name):
	for effect in effects:
		if effect.name == effect_name:
			effects.erase(effect)
	render_current_enemy()

func attack_player():
	var TWEEN_TIME = 0.15
	$Tween.interpolate_property(self, "rect_position", rect_position, rect_position + attack_player_offset, TWEEN_TIME, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	TWEEN_TIME = 0.25
	$Tween.interpolate_property(self, "rect_position", rect_position, rect_position - attack_player_offset, TWEEN_TIME, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()

func clear_existing_icons():
	for child in $BaseCard/Damage.get_children():
		child.queue_free()
	for child in $BaseCard/Health.get_children():
		child.queue_free()
	for child in $BaseCard/Effects.get_children():
		child.queue_free()
	for child in $BaseCard/Status.get_children():
		child.queue_free()

func float_card_up_and_destroy():
	var TWEEN_TIME = rand_range(.35, .45)
	$Tween.interpolate_property(self, "rect_position", rect_position, Vector2(rect_position.x, $DiscardEndYPosition.position.y), TWEEN_TIME, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	queue_free()

func rebirth_enemy():
	match enemy.name:
		"Phoenix":
			set_enemy(Ashes)
			render_current_enemy()
		"Ashes":
			set_enemy(Phoenix)
			remove_effect("Reborn")
			render_current_enemy()

func die():
	get_tree().call_group("enemies", "enemy_died", self)
	if has_effect("Reborn"):
		$Die.play()
		$EnemyArea/CollisionShape2D.disabled = true
		$AnimationPlayer.play("die")
		yield($AnimationPlayer, "animation_finished")
		$AnimationPlayer.play("flip_over")
		yield($AnimationPlayer, "animation_finished")
		rebirth_enemy()
		$AnimationPlayer.play("flip_spawn")
		yield($AnimationPlayer, "animation_finished")
		$EnemyArea/CollisionShape2D.disabled = false
	else:
		is_queued_for_deletion = true
		$Die.play()
		$EnemyArea/CollisionShape2D.disabled = true
		get_tree().call_group("Battle", "enemy_queued_for_death", self)
		$AnimationPlayer.play("die")
		yield($AnimationPlayer, "animation_finished")
		$AnimationPlayer.play("flip_over")
		yield($AnimationPlayer, "animation_finished")

func spawn_item_on_death():
	var next_card_rsc = Globals.get_randomized_item_from_list(enemy.drops)
	var next_card = Card.instance()
	get_parent().get_parent().get_node("PlayerCards").add_child(next_card)
	next_card.set_card(next_card_rsc)
	next_card.rect_position = rect_position

func take_damage(amount, is_poison=false):
	if is_poison:
		$Slash.animation = "poison"
	else:
		$Slash.animation = "default"
	if has_effect("Blunt"):
		amount -= 1
	if has_effect("Block"):
		amount = 0
		remove_effect("Block")
	if has_effect("Dodge") and amount > 0:
		randomize()
		var dodge_effect = get_effect("Dodge")
		if dodge_effect.description.begins_with("50"):
			if randi() % 2 == 0:
				$Dodge.play()
				amount = 0
				downgrade_dodge()
		elif dodge_effect.description.begins_with("25"):
			if randi() % 4 == 0:
				$Dodge.play()
				amount = 0
				downgrade_dodge()
	health -= amount
	health = max(0, health)
	if health == 0:
		die()
	elif amount > 0:
		if is_poison:
			$Poison.play()
		else:
			$TakeDamage.play()
		$AnimationPlayer.play("take_damage")
	if health > 0 and has_effect("Rage"):
		damage += 1
	render_current_enemy()

func downgrade_dodge():
	if has_effect("Dodge"):
		var dodge_effect = get_effect("Dodge")
		if dodge_effect.description.begins_with("50"):
			for effect in effects:
				if effect.name == "Dodge":
					effects.erase(effect)
			effects.push_front(Dodge_1)
		elif dodge_effect.description.begins_with("25"):
			for effect in effects:
				if effect.name == "Dodge":
					effects.erase(effect)
			effects.push_front(Dodge_2)

func get_total_enemies_in_mob():
	var count = 0
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.has_effect("Mob") and !enemy.is_queued_for_deletion:
			count += 1
	return count

func get_enemy_damage():
	var total_damage = enemy.damage
	if has_effect("Mob"):
		total_damage += get_total_enemies_in_mob()
	return total_damage

func render_current_enemy():
	if !enemy or !has_node("BaseCard"):
		return
	var base_card_dupe = $BaseCard.duplicate(DUPLICATE_USE_INSTANCING)
	add_child(base_card_dupe)
	move_child(base_card_dupe, 2)
	clear_existing_icons()
	$BaseCard.hide()
	$BaseCard/Title.text = enemy.name
	if use_enemy_texture and enemy.texture:
		$BaseCard/Texture.texture = enemy.texture
		$BaseCard/Texture.show()
		$BaseCard/Title.hide()
	add_icon_for_amount(Damage, $BaseCard/Damage, damage)
	add_icon_for_amount(Health, $BaseCard/Health, health)
	add_icon_for_amount(Poisoned, $BaseCard/Status, poison)
	add_effects_icons()
	yield(get_tree().create_timer(0.05), "timeout")
	base_card_dupe.queue_free()
	$BaseCard.show()

func add_effects_icons():
	for effect in effects:
		var next_icon = Icon.instance()
		next_icon.set_icon(effect)
		$BaseCard/Effects.add_child(next_icon)

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

func spawn_in_from_x_pos(x_pos, wait_time=0.0):
	enemy_spawned()
	render_current_enemy()
	rect_position = Vector2(x_pos, $SpawnStartYPosition.position.y)
	yield(get_tree().create_timer(wait_time), "timeout")
	$AnimationPlayer.play("flip_spawn")
	var TWEEN_TIME = .35
	$Tween.interpolate_property(self, "rect_position", rect_position, Vector2(rect_position.x, $SpawnEndYPosition.position.y), TWEEN_TIME, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()
