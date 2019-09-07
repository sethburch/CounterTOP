extends "res://scripts/KinematicBody2D.gd"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	character_name = "Crumb"
	MAX_SPEED = 350
	ACCELERATION = 40
	MAX_DASH_SPEED = 1700

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
