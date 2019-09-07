extends VBoxContainer

func _ready():
	pass

var p1_anim
var p1_icon
var p2_anim
var p2_icon

func _on_GUI_p1_score_changed(p1_score):
	#$Lives/Sep.get_child(p1_score - 1).texture = load("res://ui/toast_score_filled.png")
	if $Lives/Sep.get_child_count() > p1_score - 1:
		$Lives/Sep.get_child(p1_score - 1).get_child(0).play(p1_anim)
	#Lives/Sep.get_child(p1_score - 1).texture.set_frame_texture()

func _on_GUI_p2_score_changed(p2_score):
	#$Lives/Sep.get_child(i).texture = load("res://ui/toast_score_filled.png")
	if $Lives/Sep.get_child_count() > p2_score - 1:
		$Lives/Sep.get_child(p2_score - 1).get_child(0).play(p2_anim)


func _on_GUI_p1_info(p1_name):
	$Control/NameBG/Label.text = p1_name
	set_p1(p1_name)
	for i in $Lives/Sep.get_child_count():
		$Lives/Sep.get_child(i).texture = load(p1_icon)

func _on_GUI_p2_info(p2_name):
	$Control/NameBG/Label.text = p2_name
	set_p2(p2_name)
	for i in $Lives/Sep.get_child_count():
		$Lives/Sep.get_child(i).texture = load(p2_icon)
	
func set_p1(name):
	if name == "Crumb":
		p1_anim = "toast_anim"
		p1_icon = "res://assets/ui/character_select/toast_score_blank.png"
	if name == "Chilli":
		p1_anim = "fridge_anim"
		p1_icon = "res://assets/ui/character_select/fridge_score_icon_blank.png"
	if name == "Micro":
		p1_anim = "micro_anim"
		p1_icon = "res://assets/ui/character_select/micro_icon2.png"
	
func set_p2(name):
	if name == "Crumb":
		p2_anim = "toast_anim"
		p2_icon = "res://assets/ui/character_select/toast_score_blank.png"
	if name == "Chilli":
		p2_anim = "fridge_anim"
		p2_icon = "res://assets/ui/character_select/fridge_score_icon_blank.png"
	if name == "Micro":
		p2_anim = "micro_anim"
		p2_icon = "res://assets/ui/character_select/micro_icon2.png"
