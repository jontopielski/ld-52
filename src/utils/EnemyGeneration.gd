extends Node

const BaseEnemy = preload("res://resources/enemies/BaseEnemy.tres")

enum EnemyStat { DAMAGE, HEALTH }
func generate_enemy(enemy_spend, enemy_count, test_enemy_effect=null):
	var next_enemy = BaseEnemy.duplicate()
	var enemy_effect = Globals.get_next_enemy_effect(enemy_count)
	if test_enemy_effect:
		enemy_effect = test_enemy_effect
	next_enemy.effects.push_back(enemy_effect)
	if Globals.is_facing_boss():
		next_enemy.effects.push_back(Globals.get_next_enemy_effect(enemy_count))
	match enemy_count:
		1:
			next_enemy.damage = 3
			next_enemy.health = 5
		2:
			next_enemy.damage = 2
			next_enemy.health = 3
		3:
			next_enemy.damage = 1
			next_enemy.health = 2
	while Sort.get_enemy_weight(next_enemy) < enemy_spend:
		if randi() % 7 <= 2:
			next_enemy.damage += 1
		else:
			next_enemy.health += 1
	if Globals.show_debug_values:
		next_enemy.name = str(Sort.get_enemy_weight(next_enemy))
	if Sort.get_enemy_weight(next_enemy) > enemy_spend * 1.5:
		print("Regenerating enemy..")
		return generate_enemy(enemy_spend * 1.025, enemy_count, test_enemy_effect)
	return next_enemy

func get_random_enemy_name():
	var next_enemy_name = ""
	for i in range(0, randi() % 2 + 1):
		next_enemy_name += get_random_consonant()
		next_enemy_name += get_random_vowel()
	next_enemy_name += get_random_enemy_ending()
	if len(next_enemy_name) > 8:
		return get_random_enemy_name()
	else:
		return next_enemy_name

func get_random_vowel():
	var vowels = ['a', 'e', 'i', 'o', 'u', 'y']
	vowels.shuffle()
	return vowels.front()

func get_random_consonant():
	var letters = ['b', 'c', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 'n', \
		'p', 'q', 'r', 's', 't', 'v', 'w', 'x', 'z']
	letters.shuffle()
	return letters.front()

func get_random_enemy_ending():
	var endings = ['lin', 'bat', 'll', 'me', 'xin', 'rg', 're', 'rc', \
		'rf', 'rd', 'man', 'le']
	endings.shuffle()
	return endings.front()
