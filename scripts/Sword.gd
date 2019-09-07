extends Area2D

signal attack_finished
signal killed_player

onready var animated_sprite = $AnimatedSprite

enum STATES {IDLE, ATTACK, COOLDOWN}
var current_state = STATES.IDLE
onready var main_camera = get_parent().get_parent()

export(int) var damage = 1

export(bool) var can_reflect = false

func _ready():
	animated_sprite.playing = false
	visible = false
	set_physics_process(false)

func attack():
	if current_state != STATES.ATTACK:
		_change_state(STATES.ATTACK)
	
func rotate(dir):
	var attack_point = dir * 1000
	rotation = attack_point.angle()
	if get_rotation_degrees() > -90 and get_rotation_degrees() < 90:
		$AnimatedSprite.flip_v = false
	else:
		$AnimatedSprite.flip_v = true
	
func _change_state(new_state):
	current_state = new_state
	match current_state:
		STATES.IDLE:
			set_physics_process(false)
			animated_sprite.playing = false
			visible = false
		STATES.ATTACK:
			set_physics_process(true)
			animated_sprite.playing = true
			animated_sprite.frame = 0
			visible = true
			
func _physics_process(delta):
	var overlapping_bodies = get_overlapping_bodies()
	if not overlapping_bodies:
		return

	for body in overlapping_bodies:
		#print_debug(body.get_name())
		if not body.is_in_group("player"):
			return
		if is_owner(body):
			return
		if !body.invincible:
			body.hit()
			body.knockback(self.get_parent(), 300)
			main_camera.shake(.3, 15, 25)
			emit_signal("killed_player")
		set_physics_process(false)
	
func is_owner(node):
	return get_parent().get_path() == node.get_path()

func _on_AnimatedSprite_animation_finished():
	if current_state != STATES.IDLE:
		_change_state(STATES.IDLE)
	emit_signal("attack_finished")

func _on_Player_start_attack():
	play_sound("res://assets/sound/fx/sword_hum", 1)
	play_sound("res://assets/sound/fx/attack_start", 1)

func _on_Player_end_attack():
	$SoundEffects.stop()
	for i in $SoundEffects.get_child_count():
		$SoundEffects.get_child(i).queue_free()
	play_sound("res://assets/sound/fx/attack_finish", 1)
	
func play_sound(path, amount_of_sounds):
	if $SoundEffects.playing:
		var asp = $SoundEffects.duplicate(DUPLICATE_USE_INSTANCING)
		$SoundEffects.add_child(asp)
		asp.stream = load(path + str(randi() % amount_of_sounds) + ".wav")
		asp.pitch_scale = rand_range(0.90, 1.1)
		asp.play()
		yield(asp, "finished")
		asp.queue_free()
	else:
		$SoundEffects.stream = load(path + str(randi() % amount_of_sounds) + ".wav")
		$SoundEffects.pitch_scale = rand_range(0.90, 1.1)
		$SoundEffects.play()
