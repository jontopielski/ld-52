extends Sprite

const BackShatter = preload("res://sprites/effects/ShatterCardBack.png")

func set_back_shatter():
	texture = BackShatter

func _ready():
	if get_tree().current_scene.name == "Battle":
		$Break.play()

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
