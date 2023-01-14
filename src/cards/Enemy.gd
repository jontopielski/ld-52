tool
extends Control

const Icon = preload("res://src/cards/Icon.tscn")
const Damage = preload("res://resources/icons/Damage.tres")
const Health = preload("res://resources/icons/Health.tres")
const Card = preload("res://src/cards/Card.tscn")

export(Resource) var enemy = null setget set_enemy

var damage = 0
var health = 0

var attack_player_offset = Vector2(0, 20)

func set_enemy(_enemy):
	enemy = _enemy
	damage = enemy.damage
	health = enemy.health
	if Engine.editor_hint:
		render_current_enemy()

func _ready():
	render_current_enemy()

func attack_player():
	var TWEEN_TIME = 0.25
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

func die():
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

func reduce_health(amount):
	health -= amount
	health = max(0, health)
	render_current_enemy()
	if health == 0:
		die()
	else:
		$TakeDamage.play()
		$AnimationPlayer.play("take_damage")

func render_current_enemy():
	if !enemy or !has_node("BaseCard"):
		return
	clear_existing_icons()
	$BaseCard/Title.text = enemy.name
	add_icon_for_amount(Damage, $BaseCard/Damage, damage)
	add_icon_for_amount(Health, $BaseCard/Health, health)

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

func spawn_in_from_x_pos(x_pos):
	render_current_enemy()
	rect_position = Vector2(x_pos, $SpawnStartYPosition.position.y)
	$AnimationPlayer.play("flip_spawn")
	var TWEEN_TIME = .35
	$Tween.interpolate_property(self, "rect_position", rect_position, Vector2(rect_position.x, $SpawnEndYPosition.position.y), TWEEN_TIME, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()
