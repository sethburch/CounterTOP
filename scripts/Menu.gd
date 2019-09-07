extends VBoxContainer

var move_up
var move_down
var select
var menu_changed

var menu = ["Rematch", "Quit"]

var menu_option = 0

signal menu_changed
signal menu_select

func _ready():
	menu_changed = true
	set_process(false)

func _process(delta):
	move_up = Input.is_action_just_pressed("move_upP1") or Input.is_action_just_pressed("move_upP2")
	move_down = Input.is_action_just_pressed("move_downP1") or Input.is_action_just_pressed("move_downP2")
	select = Input.is_action_just_pressed("any_keyP1") or Input.is_action_just_pressed("any_keyP2")
	
	if move_up:
		emit_signal("menu_changed")
		menu_option+=1
		menu_changed = true
	elif move_down:
		emit_signal("menu_changed")
		menu_option-=1
		menu_changed = true
		
	if menu_option < 0:
		menu_option = menu.size()-1
	if menu_option > menu.size()-1:
		menu_option = 0
		
	if menu_option == 0 and menu_changed:
		$MenuAnim.play("option1_select")
		menu_changed = false
	if menu_option == 1 and menu_changed:
		$MenuAnim.play("option2_select")
		menu_changed = false
		
	if select:
		emit_signal("menu_select")
		set_process(false)
		match menu_option:
			0:
				#get_tree().change_scene("CharacterSelect.tscn")
				get_tree().reload_current_scene()
			1:
				get_tree().change_scene("res://scenes/CharacterSelect.tscn")

#func _on_MenuAnim_animation_finished(anim_name):
#	$MenuAnim.stop()
