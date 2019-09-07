extends "res://scripts/KinematicBody2D.gd"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	character_name = "Chilli"
	$Gun/Hitbox/Hitbox8.disabled = false
	$Gun/Hitbox/Hitbox9.disabled = false
	shoot_animation = "beam_big"
	MAX_SPEED = 280
	ACCELERATION = 25
	MAX_DASH_SPEED = 1400

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass