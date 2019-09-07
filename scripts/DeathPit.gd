extends Area2D

signal kill_player

func _ready():
	pass

func _on_DeathPit_body_entered(body):
	if body.is_in_group("player"):
		body.kill()
