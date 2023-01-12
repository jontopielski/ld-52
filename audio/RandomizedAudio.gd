extends AudioStreamPlayer

export(float, 0.0, 1.0) var pitch_randomness = 0.1

var last_pitch = 1.0

func play(from_position=0.0):
	
	randomize()
	pitch_scale = rand_range(1.0 - pitch_randomness, 1.0 + pitch_randomness)
	
	while abs(pitch_scale - last_pitch) < pitch_randomness / 2.0:
		randomize()
		pitch_scale = rand_range(1.0 - pitch_randomness, 1.0 + pitch_randomness)
	
	last_pitch = pitch_scale
	
	.play(from_position)
