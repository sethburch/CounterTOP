extends RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func fling_body(body):
	apply_central_impulse(transform.origin - body.transform.origin)