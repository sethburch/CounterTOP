extends Line2D

func _ready():
	if get_parent().player_num == 1:
		default_color = Global.BLUE
	else:
		default_color = Global.RED

func _on_Player_hit_effect_start():
	width = 50
	global_position = Vector2(0, 0)
	global_rotation = 0
	set_point_position(0, Vector2(get_parent().global_position.x - 200, -1000))
	set_point_position(1, Vector2(get_parent().global_position.x, get_parent().global_position.y))
	set_point_position(2, Vector2(get_parent().global_position.x + 200, 1000))

func _on_Player_hit_effect_over():
	width = 0