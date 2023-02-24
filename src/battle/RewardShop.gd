extends Control

const ShopItem = preload("res://src/map/ShopItem.tscn")
const RewardWindowPost = preload("res://src/battle/RewardWindowPost.tres")
const TwoCards = preload("res://resources/rewards/2-Cards.tres")
const ThreeCards = preload("res://resources/rewards/3-Cards.tres")

func _ready():
	clear_all_shop_items()
	if Globals.has_relic("Three") and TwoCards in Globals.rewards:
		Globals.remove_reward(TwoCards)
		Globals.add_reward(ThreeCards)
	for reward in Globals.rewards:
		var next_shop_item = ShopItem.instance()
		$Window/Content/Items.add_child(next_shop_item)
		next_shop_item.set_resource(reward)
		next_shop_item.set_cooldown(Globals.reward_to_cooldown_map[reward])

func spawn_in():
	$Window/Cover.show()
	$Window/Content.hide()
	$Window.rect_scale = Vector2.ZERO
	var tween_time = 0.4
	$Tween.interpolate_property($Window, "rect_scale", Vector2.ZERO, Vector2.ONE, tween_time, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()

func refill_selected():
	for shop_item in $Window/Content/Items.get_children():
		shop_item.disabled = false
		shop_item.set_everything_black()
		shop_item.set_reward_symbols()

func clear_all_shop_items():
	for shop_item in $Window/Content/Items.get_children():
		shop_item.queue_free()

func card_selected():
	$Window/MouseBlock.show()

func item_selected():
	$Window/MouseBlock.show()
	get_tree().call_group("Terminal", "clear_terminal_text")
	yield(get_tree().create_timer(0.65), "timeout")
	TransitionScreen.transition_to(Globals.Map)

func _on_Tween_tween_all_completed():
	$Window.add_stylebox_override("panel", RewardWindowPost)
	$Window/Content.show()
	$Window/Cover.hide()
