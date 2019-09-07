extends TextureRect

export(String) var anim = "p1_blink"
export(String) var anim_selected = "p1_selected"
export(String) var anim_shine = "p1_shine"

func _ready():
	$AnimationPlayer.play(anim)
	
func select_anim():
	$AnimationPlayer.play(anim_shine)
	#rect_position.y += 10
	
#func blink_anim():
#	$AnimationPlayer.play(anim)
#	pass
	
func deselect():
	$AnimationPlayer.play(anim)
	
func current_anim():
	return $AnimationPlayer.current_animation
	
func selected_anim():
	$AnimationPlayer.play(anim_selected)

func _on_Timer_timeout():
	$AnimationPlayer.play(anim_shine)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == anim_shine:
		$AnimationPlayer.play(anim_selected)
		#rect_position.y -= 10
