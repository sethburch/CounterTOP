extends Node

signal p1_info
signal p2_info
signal start_game

var characters = ["res://scenes/Crumb.tscn", "res://scenes/Fridge.tscn", "res://scenes/Micro.tscn"]

func _ready():
#	$MusicTrack.stream = load("res://sound/music/city_track0.ogg")
#	$MusicTrack.play()
	var p1 = load(characters[Global.p1_character])
	var p2 = load(characters[Global.p2_character])
	var p1_inst = p1.instance()
	var p2_inst = p2.instance()
	p1_inst.set_name("Player1")
	p2_inst.set_name("Player2")
	p1_inst.get_node("Sprite").material.set_shader_param("outline_color", Color(Global.RED))
	p2_inst.get_node("Sprite").material.set_shader_param("outline_color", Color(Global.BLUE))
	$MainCamera.add_child(p1_inst)
	$MainCamera.add_child(p2_inst)
	
	$MainCamera/Player1.player_num = 1
	$MainCamera/Player1.jump_input = "jumpP1"
	$MainCamera/Player1.attack_input = "attackP1"
	$MainCamera/Player1.move_right_input = "move_rightP1"
	$MainCamera/Player1.move_up_input = "move_upP1"
	$MainCamera/Player1.move_left_input = "move_leftP1"
	$MainCamera/Player1.move_down_input = "move_downP1"
	$MainCamera/Player1.dash_input = "dashP1"
	$MainCamera/Player1.shoot_input = "shootP1"
	
	$MainCamera/Player2.player_num = 2
	$MainCamera/Player2.jump_input = "jumpP2"
	$MainCamera/Player2.attack_input = "attackP2"
	$MainCamera/Player2.move_right_input = "move_rightP2"
	$MainCamera/Player2.move_up_input = "move_upP2"
	$MainCamera/Player2.move_left_input = "move_leftP2"
	$MainCamera/Player2.move_down_input = "move_downP2"
	$MainCamera/Player2.dash_input = "dashP2"
	$MainCamera/Player2.shoot_input = "shootP2"
	
	#$MainCamera/Player1/Sprite.material.set_shader_param("outline_color", Color(Global.RED))
	#$MainCamera/Player2/Sprite.material.set_shader_param("outline_color", Color(Global.BLUE))
	
	$MainCamera/Player1/Sword.set_collision_mask_bit(2, true)
	$MainCamera/Player1/Gun/AimRay.set_collision_mask_bit(2, true)
	$MainCamera/Player1/Gun/Hitbox.set_collision_mask_bit(2, true)
	$MainCamera/Player2/Sword.set_collision_mask_bit(1, true)
	$MainCamera/Player2/Gun/AimRay.set_collision_mask_bit(1, true)
	$MainCamera/Player2/Gun/Hitbox.set_collision_mask_bit(1, true)

	$MainCamera/Player1.set_collision_mask_bit(1, true)
	$MainCamera/Player2.set_collision_mask_bit(2, true)
	$MainCamera/Player1.set_collision_layer_bit(1, true)
	$MainCamera/Player2.set_collision_layer_bit(2, true)
	
	$MainCamera/Player1/Gun/AimRay.set_collision_mask_bit(12, true)
	$MainCamera/Player1/Gun/Hitbox.set_collision_mask_bit(12, true)
	$MainCamera/Player2/Gun/AimRay.set_collision_mask_bit(11, true)
	$MainCamera/Player2/Gun/Hitbox.set_collision_mask_bit(11, true)
	
	$MainCamera/Player1/Reflect.set_collision_mask_bit(11, true)
	$MainCamera/Player2/Reflect.set_collision_mask_bit(12, true)
	$MainCamera/Player1/Reflect.set_collision_layer_bit(11, true)
	$MainCamera/Player2/Reflect.set_collision_layer_bit(12, true)
	
	$MainCamera/Player1/Gun.connect("shoot_finished", self, "_on_Gun_shoot_finished")
	$MainCamera/Player2/Gun.connect("shoot_finished", self, "_on_Gun_shoot_finished")
	
	$MainCamera/Player1.connect("player_dead", $GUILayer/GUI, "_on_Player1_player_dead")
	$MainCamera/Player2.connect("player_dead", $GUILayer/GUI, "_on_Player2_player_dead")
	$MainCamera/Player1.connect("player_suicide", $MainCamera/Player2, "_on_Player1_player_suicide")
	$MainCamera/Player2.connect("player_suicide", $MainCamera/Player1, "_on_Player2_player_suicide")
	
	$MainCamera/Player1.connect("player_win", $GUILayer/GUI, "_on_Player_player_win")
	$MainCamera/Player2.connect("player_win", $GUILayer/GUI, "_on_Player_player_win")
	$MainCamera/Player1.connect("player_win", $MainCamera, "_on_Player_player_win")
	$MainCamera/Player2.connect("player_win", $MainCamera, "_on_Player_player_win")
	
	$MainCamera/Player1.connect("focus_player", $MainCamera, "_on_Player_focus_player")
	$MainCamera/Player2.connect("focus_player", $MainCamera, "_on_Player_focus_player")
	
	$MainCamera/Player1.global_position = $P1Respawn.global_position
	$MainCamera/Player2.global_position = $P2Respawn.global_position
	$MainCamera/Player1.respawn_point = "NeutralRespawn"
	$MainCamera/Player2.respawn_point = "NeutralRespawn"
	
	$MainCamera/Player1/Gun/Light2D.color = Global.RED
	$MainCamera/Player2/Gun/Light2D.color = Global.BLUE
	#$MainCamera/Player2.set_scale(Vector2(-1, 1))
	#$MainCamera/Player2.facing_right = false
	
	emit_signal("p1_info", p1_inst.character_name) # change to p1 character select whenever character select screen is implemented, and just emit a signal that tells which character was selected. then the info about the character can come from the inherited script within the character
	emit_signal("p2_info", p2_inst.character_name)
	
	emit_signal("start_game")

func _on_Gun_shoot_finished(point1, point2):
	#var post_shoot_effect = load("GunLine.tscn").instance()
	#add_child()
	var scene = load("res://scenes/PostShootEffect.tscn")
	var post_shoot_effect = scene.instance()
	add_child(post_shoot_effect)
	#print_debug(str(point2))
	post_shoot_effect.add_point(point1)

	post_shoot_effect.add_point(point2)
	
func focus_player_1():
	print_debug("1")
	$MainCamera/Player1.focus_player()
	
func focus_player_2():
	print_debug("2")
	$MainCamera/Player2.focus_player()

func enable_movement():
	print_debug("test")
	$MainCamera/Player1.enable_process()
	$MainCamera/Player2.enable_process()