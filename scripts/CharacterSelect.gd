extends Control

onready var p1_selector = preload("res://scenes/P1Selector.tscn")
onready var p2_selector = preload("res://scenes/P2Selector.tscn")
onready var p1p2_selector = preload("res://scenes/P1P2Selector.tscn")

onready var toast_texture = load("res://assets/ui/character_select/toast_portrait.png")
onready var fridge_texture = load("res://assets/ui/character_select/fridge_portrait.png")

var p1_menu = 0
var p2_menu = 3

var p1_selected = false
var p2_selected = false

var played_fade_in = false

var p1s
var p2s
var p1p2s

var p1_changed
var p2_changed

enum CHAR {TOAST, FRIDGE, MICRO}
	
func _ready():
	p1s = p1_selector.instance()
	p2s = p2_selector.instance()
	p1p2s = p1p2_selector.instance()
	$P1/Stage/AnimationPlayer.play("stage")
	$P1/P1Anim.play("float")
	$P2/P2Anim.play("float")
	
	
func _process(delta):
	if !played_fade_in:
		$Transition/TransitionAnim.play_backwards("transition")
		played_fade_in = true
		
	if !p1_selected:
		if Input.is_action_just_pressed("move_rightP1"):
			$Select.get_child(p1_menu).remove_child(p1s)
			$Select.get_child(p1_menu).remove_child(p1p2s)
			p1_menu+=1
	#		p1s.queue_free()
	#		p1s = p1_selector.instance()
	#		p1p2s.queue_free()
	#		p1p2s = p1p2_selector.instance()
			p1_changed = true
		if Input.is_action_just_pressed("move_leftP1"):
			$Select.get_child(p1_menu).remove_child(p1s)
			$Select.get_child(p1_menu).remove_child(p1p2s)
			p1_menu-=1
	#		p1s.queue_free()
	#		p1s = p1_selector.instance()
	#		p1p2s.queue_free()
	#		p1p2s = p1p2_selector.instance()
			p1_changed = true
	if !p2_selected:
		if Input.is_action_just_pressed("move_rightP2"):
			$Select.get_child(p2_menu).remove_child(p2s)
			$Select.get_child(p1_menu).remove_child(p1p2s)
			p2_menu+=1
	#		p2s.queue_free()
	#		p2s = p2_selector.instance()
	#		p1p2s.queue_free()
	#		p1p2s = p1p2_selector.instance()
			p2_changed = true
		if Input.is_action_just_pressed("move_leftP2"):
			$Select.get_child(p2_menu).remove_child(p2s)
			$Select.get_child(p1_menu).remove_child(p1p2s)
			p2_menu-=1
	#		p2s.queue_free()
	#		p2s = p2_selector.instance()
	#		p1p2s.queue_free()
	#		p1p2s = p1p2_selector.instance()
			p2_changed = true
	
	if p1_menu > 3:
		p1_menu = 0
	if p2_menu > 3:
		p2_menu = 0
	if p1_menu < 0:
		p1_menu = 3
	if p2_menu < 0:
		p2_menu = 3
		
	if p1_menu == p2_menu:
		if $Select.get_child(p1_menu).has_node(p1s.name):
			$Select.get_child(p1_menu).remove_child(p1s)
		if $Select.get_child(p1_menu).has_node(p2s.name):
			$Select.get_child(p1_menu).remove_child(p2s)
		if $Select.get_child(p1_menu).get_child_count() < 1:
			$Select.get_child(p1_menu).add_child(p1p2s)
		
	if $Select.get_child(p1_menu).get_child_count() < 1:
		$Select.get_child(p1_menu).add_child(p1s)
	if $Select.get_child(p2_menu).get_child_count() < 1:
		$Select.get_child(p2_menu).add_child(p2s)
		
		
	match p1_menu:
		CHAR.TOAST:
			$P1/Label.text = "Crumb"
			$P1/Description.text = "+ Movement"
			if !p1_selected:
				#$P1/P1Anim.play("float")
				$P1/P1Portrait.texture = toast_texture
				$P1/P1Sprite/AnimationPlayer.play("toast_spin")
				$P1/P1Sprite/AnimationPlayer.playback_speed = 1
				if Input.is_action_just_pressed("any_keyP1"):
					$Select.get_child(p1_menu).get_child(0).select_anim()
					select_anim(1)
					$P1/P1Anim.seek(.5, true)
					$P1/P1Anim.play("toast_flash")
					p1_selected = true
			else:
				$P1/P1Sprite/AnimationPlayer.play("toast_idle")
				$P1/P1Sprite/AnimationPlayer.playback_speed = .5
				if Input.is_action_just_pressed("any_keyP1"):
					$P1/P1Anim.play("float")
					play_sound("res://assets/sound/fx/deselect", 1, false)
					p1_selected = false
					$Select.get_child(p1_menu).get_child(0).deselect()
		CHAR.FRIDGE:
			$P1/Label.text = "Chilli"
			$P1/Description.text = "+ Range\n- Movement"
			if !p1_selected:
				#$P1/P1Anim.play("float")
				$P1/P1Portrait.texture = fridge_texture
				$P1/P1Sprite/AnimationPlayer.play("fridge_spin")
				$P1/P1Sprite/AnimationPlayer.playback_speed = 1
				if Input.is_action_just_pressed("any_keyP1"):
					$Select.get_child(p1_menu).get_child(0).select_anim()
					select_anim(1)
					$P1/P1Anim.seek(.5, true)
					$P1/P1Anim.play("fridge_flash")
					p1_selected = true
			else:
				$P1/P1Sprite/AnimationPlayer.play("fridge_idle")
				$P1/P1Sprite/AnimationPlayer.playback_speed = .5
				if Input.is_action_just_pressed("any_keyP1"):
					$P1/P1Anim.play("float")
					play_sound("res://assets/sound/fx/deselect", 1, false)
					p1_selected = false
					$Select.get_child(p1_menu).get_child(0).deselect()
		CHAR.MICRO:
			$P1/Label.text = "Micro"
			$P1/Description.text = "Better Beams"
			if !p1_selected:
				#$P1/P1Anim.play("float")
				$P1/P1Portrait.texture = fridge_texture
				$P1/P1Sprite/AnimationPlayer.play("fridge_spin")
				$P1/P1Sprite/AnimationPlayer.playback_speed = 1
				if Input.is_action_just_pressed("any_keyP1"):
					$Select.get_child(p1_menu).get_child(0).select_anim()
					select_anim(1)
					$P1/P1Anim.seek(.5, true)
					$P1/P1Anim.play("fridge_flash")
					p1_selected = true
			else:
				$P1/P1Sprite/AnimationPlayer.play("fridge_idle")
				$P1/P1Sprite/AnimationPlayer.playback_speed = .5
				if Input.is_action_just_pressed("any_keyP1"):
					$P1/P1Anim.play("float")
					play_sound("res://assets/sound/fx/deselect", 1, false)
					p1_selected = false
					$Select.get_child(p1_menu).get_child(0).deselect()
	
	if p1_changed:
		if !p1_selected:
			play_sound("res://assets/sound/fx/menu_move", 1, false)
			$P1/P1Anim.stop()
			$P1/P1Anim.play("slide")
			p1_changed = false
			p1_selected = false
			$Select.get_child(p1_menu).get_child(0).deselect()
		
	

##########################################################

	match p2_menu:
		CHAR.TOAST:
			$P2/Label.text = "Crumb"
			if !p2_selected:
				#$P2/P2Anim.play("float")
				$P2/P2Portrait.texture = toast_texture
				$P2/P2Sprite/AnimationPlayer.play("toast_spin")
				$P2/P2Sprite/AnimationPlayer.playback_speed = 1
				if Input.is_action_just_pressed("any_keyP2"):
					$Select.get_child(p2_menu).get_child(0).select_anim()
					select_anim(2)
					$P2/P2Anim.seek(.5, true)
					$P2/P2Anim.play("toast_flash")
					p2_selected = true
			else:
				$P2/P2Sprite/AnimationPlayer.play("toast_idle")
				$P2/P2Sprite/AnimationPlayer.playback_speed = .5
				if Input.is_action_just_pressed("any_keyP2"):
					$P2/P2Anim.play("float")
					play_sound("res://assets/sound/fx/deselect", 1, false)
					p2_selected = false
					$Select.get_child(p2_menu).get_child(0).deselect()
		CHAR.FRIDGE:
			$P2/Label.text = "Chilli"
			if !p2_selected:
				#$P2/P2Anim.play("float")
				$P2/P2Portrait.texture = fridge_texture
				$P2/P2Sprite/AnimationPlayer.play("fridge_spin")
				$P2/P2Sprite/AnimationPlayer.playback_speed = 1
				if Input.is_action_just_pressed("any_keyP2"):
					$Select.get_child(p2_menu).get_child(0).select_anim()
					select_anim(2)
					$P2/P2Anim.seek(.5, true)
					$P2/P2Anim.play("fridge_flash")
					p2_selected = true
			else:
				$P2/P2Sprite/AnimationPlayer.play("fridge_idle")
				$P2/P2Sprite/AnimationPlayer.playback_speed = .5
				if Input.is_action_just_pressed("any_keyP2"):
					$P2/P2Anim.play("float")
					play_sound("res://assets/sound/fx/deselect", 1, false)
					p2_selected = false
					$Select.get_child(p2_menu).get_child(0).deselect()
		CHAR.MICRO:
			$P2/Label.text = "Micro"
			$P2/Description.text = "Better Beams"
			if !p2_selected:
				#$P2/P2Anim.play("float")
				$P2/P2Portrait.texture = fridge_texture
				$P2/P2Sprite/AnimationPlayer.play("fridge_spin")
				$P2/P2Sprite/AnimationPlayer.playback_speed = 1
				if Input.is_action_just_pressed("any_keyP2"):
					$Select.get_child(p2_menu).get_child(0).select_anim()
					select_anim(1)
					$P2/P2Anim.seek(.5, true)
					$P2/P2Anim.play("fridge_flash")
					p2_selected = true
			else:
				$P2/P2Sprite/AnimationPlayer.play("fridge_idle")
				$P2/P2Sprite/AnimationPlayer.playback_speed = .5
				if Input.is_action_just_pressed("any_keyP2"):
					$P2/P2Anim.play("float")
					play_sound("res://assets/sound/fx/deselect", 1, false)
					p2_selected = false
					$Select.get_child(p2_menu).get_child(0).deselect()
	
	if p2_changed:
		play_sound("res://assets/sound/fx/menu_move", 1, false)
		$P2/P2Anim.stop()
		$P2/P2Anim.play("slide")
		p2_changed = false
		p2_selected = false
		$Select.get_child(p2_menu).get_child(0).deselect()
	
	if p1_selected:
		
		if $Select.get_child(p1_menu).get_child(0).current_anim() != "p1_shine" and $Select.get_child(p1_menu).get_child(0).current_anim() != "p1p2_shine":
			$Select.get_child(p1_menu).get_child(0).selected_anim()
			if p2_selected:
				print_debug("go to stage select")
				next()
				
			
	if p2_selected:
		if $Select.get_child(p2_menu).get_child(0).current_anim() != "p2_shine" and $Select.get_child(p1_menu).get_child(0).current_anim() != "p1p2_shine":
			$Select.get_child(p2_menu).get_child(0).selected_anim()
			if p1_selected:
				print_debug("go to stage select")
				next()

func select_anim(player):
	if player == 1:
		play_sound("res://assets/sound/fx/menu_select", 1, false)
		$Select.get_child(p1_menu).rect_position.y += 10
		$P1/P1Sprite/Shine/AnimationPlayer.play("shine")
		$TimerP1.start()
	if player == 2:
		play_sound("res://assets/sound/fx/menu_select", 1, false)
		$Select.get_child(p2_menu).rect_position.y += 10
		$P2/P2Sprite/Shine/AnimationPlayer.play("shine")
		$TimerP2.start()
	
func _on_P1Anim_animation_finished(anim_name):
	if anim_name == "slide":
		$P1/P1Anim.play("float")
	if anim_name == "flash":
		$P1/P1Anim.play("idle")

func _on_P2Anim_animation_finished(anim_name):
	if anim_name == "slide":
		$P2/P2Anim.play("float")
	if anim_name == "flash":
		$P1/P1Anim.play("idle")

func _on_TimerP1_timeout():
	$Select.get_child(p1_menu).rect_position.y = 0

func _on_TimerP2_timeout():
	$Select.get_child(p2_menu).rect_position.y = 0

func next():
	Global.p1_character = p1_menu
	Global.p2_character = p2_menu
	$Transition/TransitionAnim.play("transition")

func _on_TransitionAnim_animation_finished(anim_name):
	if p1_selected and p2_selected:
		get_tree().change_scene("res://scenes/MapSelect.tscn")
		
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
	
