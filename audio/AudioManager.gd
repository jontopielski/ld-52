extends Node2D

func play_sound(sfx_name):
	if $Sounds.has_node(sfx_name):
		$Sounds.get_node(sfx_name).play()
