extends AudioStreamPlayer

func is_playing( from_position=0.0 ):
	if !playing:
		.play(from_position)
	else:
