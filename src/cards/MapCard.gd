extends Button

export(Resource) var card = null setget set_card
var move_offset = Vector2(0, 5)
var resting_position = Vector2.ZERO
var preview_card = null

func set_card(_card):
	card = _card
	$BaseCard/Title.text = card.name
	$BaseCard/CardStats.set_card(card)

func _on_MapCard_mouse_entered():
	$Tween.stop_all()
	$Tween.interpolate_property(self, "rect_position", rect_position, resting_position - move_offset, .25, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()
	$DelayShowTimer.start()

func _on_MapCard_mouse_exited():
	$DelayShowTimer.stop()
	$Tween.stop_all()
	$Tween.interpolate_property(self, "rect_position", rect_position, resting_position, .25, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()

func _on_DelayShowTimer_timeout():
	return

func _on_Tween_tween_completed(object, key):
	if rect_position == resting_position - move_offset:
		pass
