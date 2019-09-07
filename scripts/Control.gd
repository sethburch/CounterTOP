extends Control

signal p1_score_changed(p1_score)
signal p2_score_changed(p2_score)

signal p1_info(p1_name)
signal p2_info(p2_name)

func _ready():
	$Transition/TransitionAnim.play_backwards("transition")

func _on_Player1_player_dead(p1_score):
	emit_signal("p1_score_changed", p1_score)

func _on_Player2_player_dead(p2_score):
	emit_signal("p2_score_changed", p2_score)
#
#func _on_Player1_player_suicide():
#	emit_signal("p2_score_changed", p2_score)
#
#func _on_Player2_player_suicide():
#	emit_signal("p1_score_changed", p1_score)


func _on_World_p1_info(p1_name):
	emit_signal("p1_info", p1_name)

func _on_World_p2_info(p2_name):
	emit_signal("p2_info", p2_name)


#func _on_Player1_player_win(player):
#	player_win(player)

#func _on_Player2_player_win(player):
#	player_win(player)

func _on_Player_player_win(player):
	player_win(player)

func _on_TransitionAnim_animation_finished(anim_name):
	#get_tree().paused = true
	pass

func start_game():
	$StartGame/AnimationPlayer.play("default")

func player_win(player):
	$Transition/shadow1.visible = true
	$Transition/shadow2.visible = true
	$Transition/Name.text = player.character_name
	$Transition/TransitionAnim.play("transition")
	$Transition/Name/NameAnim.play("transition")
	$Transition/Wins/WinAnim.play("transition")
	$Transition/Menu/MenuAnim.play("slide")

func _on_World_start_game():
	start_game()


func play_sound(path, amount_of_sounds, pitch_shift):
	if $SoundEffects.playing:
		var asp = $SoundEffects.duplicate(DUPLICATE_USE_INSTANCING)
		add_child(asp)
		asp.stream = load(path + str(randi() % amount_of_sounds) + ".wav")
		if pitch_shift:
			asp.pitch_scale = rand_range(0.90, 1.1)
		asp.play()
		yield(asp, "finished")
		asp.queue_free()
	else:
		$SoundEffects.stream = load(path + str(randi() % amount_of_sounds) + ".wav")
		if pitch_shift:
			$SoundEffects.pitch_scale = rand_range(0.90, 1.1)
		$SoundEffects.play()

func _on_Menu_menu_changed():
	play_sound("res://assets/sound/fx/menu_move", 1, false)


func _on_Menu_menu_select():
	play_sound("res://assets/sound/fx/menu_select", 1, false)
