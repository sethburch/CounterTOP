extends Node2D
#Body Sprite
var _body = null
var _body_width
export(float,0.0,1.0,0.01) var region_rect = 0.0 setget _set_region_rect_x

func _ready():
	_body = get_node("BodySprite")
	_body_width = _body.get_texture().get_width()

func _set_region_rect_x(value):
	region_rect = value
	_update_body_region_rect_x()

func _update_body_region_rect_x():
	if(_body != null):
		var rect = _body.get_region_rect().x
		rect.pos.x = -rect * _body_width
		_body.set_region_rect(rect)