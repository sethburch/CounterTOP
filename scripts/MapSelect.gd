extends Control

var move_right
var move_left
var select

var menu = ["Haven", "Spire"]

var menu_option = 0

func _ready():
	pass

func _process(delta):
	move_right = Input.is_action_just_pressed("move_rightP1") or Input.is_action_just_pressed("move_rightP2")
	move_left = Input.is_action_just_pressed("move_leftP1") or Input.is_action_just_pressed("move_leftP2")
	select = Input.is_action_just_pressed("any_keyP1") or Input.is_action_just_pressed("any_keyP2")
	
	$Label.text = menu[menu_option]
	
	if move_left:
		menu_option+=1
		$Map/map/AnimationPlayer.play("slide_right")
	elif move_right:
		menu_option-=1
		$Map/map/AnimationPlayer.play_backwards("slide_right")
	else:
		$Map/AnimationPlayer.play("float")
		$Label/AnimationPlayer.play("float")
		
	if menu_option < 0:
		menu_option = menu.size()-1
	if menu_option > menu.size()-1:
		menu_option = 0
		
	if select:
		$Map/map/AnimationPlayer.play("zoom")
		set_process(false)
		match menu_option:
			0:
				print_debug(menu[menu_option])
			1:
				print_debug(menu[menu_option])

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "zoom":
		get_tree().change_scene("res://scenes/World.tscn")
