extends Node2D

signal shoot_finished
signal killed_player

onready var sprite = $Sprite
onready var raycast = $AimRay
onready var line = $Line2D
onready var anim_player = $Line2D/AnimationPlayer
const GUN_PARTICLE = preload("res://scenes/GunShootParticle.tscn")
const POST_SHOOT_EFFECT = preload("res://scenes/GunLine.tscn")

enum STATES {IDLE, AIM, SHOOT, COOLDOWN}
var current_state = STATES.IDLE
var hit_pos = Vector2(4000, 0)

var has_reflected = false

#var laser_color = Global.RED
var beam_color

export(int) var damage = 1
export(int) var player_num = 1

onready var main_camera = get_parent().get_parent()

func _ready():
	#connect("shoot_finished", get_parent().get_parent().get_parent(), "_on_Gun_shoot_finished")
	anim_player.seek(0.00, true)
	set_physics_process(false)
	#raycast.set_collision_mask_bit(player_num, true)
	line.visible = false
	$Light2D.visible = false
	#$Light2D.color = beam_color

func aim(dir):
	
	if current_state == STATES.COOLDOWN:
		return
	if current_state != STATES.AIM:
		_change_state(STATES.AIM)
	#if dir == Vector2(0, 1):
	#	set_rotation(-4.71239)
	#rotation += get_local_mouse_position().angle()
	#print_debug(str(dir))

	var fire_point = dir * 1000
	rotation = fire_point.angle()
	
	if current_state != STATES.SHOOT:
		line.visible = true
		#$Light2D.color = Global.RED
		#$Light2D.color = laser_color
		$Light2D.visible = true
		$Light2D.scale.x = 400
		anim_player.stop()
		anim_player.seek(0.0, true)
			
		#raycast.set_cast_to(Vector2(1000, 0))
		#if raycast.is_colliding():
			#raycast.set_cast_to(to_local(raycast.get_collision_point()))
			#raycast.set_cast_to(raycast.global_position + raycast.get_collision_point())
			#line.set_point_position(1, to_local(raycast.get_collision_point()))
			#print_debug(raycast.get_collider().get_name())
			#print_debug(raycast.get_position())
			#print_debug(raycast.get_collision_point().x - raycast.global_position.x)
			#raycast.set_cast_to(Vector2(abs(raycast.get_collision_point().x - raycast.global_position.x), 0))
			#line.set_point_position(1, Vector2(0, abs(raycast.get_collision_point().x - raycast.global_position.x)))
			#raycast.set_cast_to(raycast.global_position + raycast.get_collision_point())
		#else:
		raycast.set_cast_to(Vector2(2000, 0))
		#$Hitbox/Hitbox1.shape.b = Vector2(4000, 0)
		#$Hitbox/Hitbox2.shape.b = Vector2(4000, 0)
		#$Hitbox/Hitbox3.shape.b = Vector2(4000, 0)
		line.set_point_position(1, Vector2(0, 4000))
		$GunShootParticle.emitting = true
		
	#raycast.set_cast_to(get_local_mouse_position())
	#line.set_point_position(1, get_local_mouse_position())

func shoot(dir):
	if current_state == STATES.COOLDOWN:
		return
	_change_state(STATES.SHOOT)


func _physics_process(delta):
	$Line2D/EndCap.visible = false
	$Line2D.visible = true
	$Light2D.visible = true
	anim_player.play(get_parent().shoot_animation)
	
	if raycast.is_colliding():
		hit_pos = raycast.get_collision_point()
	else:
		hit_pos = null
		
	if hit_pos != null:
		$Line2D/EndCap.visible = true
		#raycast.set_cast_to((hit_pos - raycast.global_position).rotated(-rotation))
		$Hitbox/Hitbox1.shape.set_b((hit_pos - raycast.global_position).rotated(-rotation) + Vector2(20, 0)) #.rotated(-rotation))
		$Hitbox/Hitbox8.shape.set_b((hit_pos - raycast.global_position).rotated(-rotation) + Vector2(20, 0))
		$Hitbox/Hitbox9.shape.set_b((hit_pos - raycast.global_position).rotated(-rotation) + Vector2(20, 0))
		#$Hitbox/Hitbox4.shape.set_b(raycast.cast_to + Vector2(20, 0))
		#$Hitbox/Hitbox5.shape.set_b(raycast.cast_to + Vector2(20, 0))
		line.set_point_position(1, Vector2(hit_pos.y - raycast.global_position.y, hit_pos.x - raycast.global_position.x).rotated(rotation))
		$Line2D/EndCap.position = line.get_point_position(1)
		$Line2D/StartCap.position = line.get_point_position(0)
		$Light2D.scale.x = (hit_pos - raycast.global_position).length()/50
	else:
		#$Line2D/EndCap.visible = false
		$Light2D.scale.x = 400
		$Hitbox/Hitbox1.shape.set_b(Vector2(2000, 0))
		$Hitbox/Hitbox8.shape.set_b(Vector2(2000, 0))
		$Hitbox/Hitbox9.shape.set_b(Vector2(2000, 0))
		line.set_point_position(1, Vector2($Hitbox/Hitbox1.shape.get_b().y,  $Hitbox/Hitbox1.shape.get_b().x))
		#line.set_point_position(1, Vector2(raycast.cast_to.y - raycast.global_position.y,raycast.cast_to.x - raycast.global_position.x).rotated(rotation))
#		$Hitbox/Hitbox2.shape.set_b(Vector2(2000, 0))
#		$Hitbox/Hitbox3.shape.set_b(Vector2(2000, 0))
#		$Hitbox/Hitbox4.shape.set_b(Vector2(2000, 0))
#		$Hitbox/Hitbox5.shape.set_b(Vector2(2000, 0))	

	var overlapping_bodies = $Hitbox.get_overlapping_bodies()
	if overlapping_bodies:
		if anim_player.current_animation_position >= 0.12:
		#print_debug("test")
			for body in overlapping_bodies:
				print_debug(str(body.name))
				#hit_pos = body.global_position
				if not body.is_in_group("player"):
					return
				if is_owner(body):
					return
				#print_debug(str(body.get_node("Sword").can_reflect))
				body.hit()
				body.knockback(self.get_parent(), 3000/(body.position.distance_to(self.get_parent().position)))
				emit_signal("killed_player")
				set_physics_process(false)
	
	var overlapping_areas = $Hitbox.get_overlapping_areas()
	if overlapping_areas:
		for body in overlapping_areas:
			print_debug(body.name)
			if body.name == "Reflect":
				if !has_reflected:
					body.get_parent().play_sound("res://assets/sound/fx/reflect_hit", 1)
					body.get_parent().freeze()
					has_reflected = true
				body.get_parent().reflected()
				if line.get_point_count() <= 2:
					if hit_pos != null:
						reflect()
						
				#line.add_point(line.get_point_position(0) + Vector2(0, 50)))
	
	
	
#	var overlapping_bodies = get_overlapping_bodies()
#	if not overlapping_bodies:
#		return
#	for body in overlapping_bodies:
#		hit_pos = body.position

#	if raycast.is_colliding():
#		var player_hit = raycast.get_collider()
#		if player_hit.is_in_group("player"):
#			if is_owner(player_hit):
#				return
#
#			if !player_hit.invincible:
#				player_hit.hit()
#				player_hit.knockback(self.get_parent(), 3000/(player_hit.position.distance_to(self.get_parent().position)))
#				emit_signal("killed_player")
#			set_physics_process(false)

	
	#if raycast.is_colliding():
		#print_debug(str(raycast.get_collision_point() - raycast.global_position))
		#raycast.set_cast_to(Vector2(abs(raycast.get_collision_point().x - raycast.global_position.x), 0))
		#line.set_point_position(1, Vector2(0, abs(raycast.get_collision_point().x - raycast.global_position.x)))
		#raycast.set_cast_to(raycast.get_collision_point() - raycast.global_position)
		#line.set_point_position(1, raycast.get_collision_point() - raycast.global_position)
	#else:
		#raycast.set_cast_to(Vector2(4000, 0))
		#line.set_point_position(1, Vector2(0, 4000))
	
	
func reflect():
	line.add_point(line.get_point_position(1).reflect(hit_pos.normalized()))
	$Line2D/EndCap.visible = false
	
func rotate(dir):
	#var attack_point = dir * 1000
	rotation = dir.angle()
	if get_rotation_degrees() > -91 and get_rotation_degrees() < 91:
		$Sprite.flip_v = false
		$Line2D.rotation_degrees = -90
		$Line2D.scale.x = 1
		position.x = 15
	else:
		$Sprite.flip_v = true
		$Line2D.rotation_degrees = -90
		$Line2D.scale.x = -1
		position.x = -4
	
func is_owner(node):
	return get_parent().get_path() == node.get_path()

func _change_state(new_state):
	current_state = new_state
	match current_state:
		STATES.IDLE:
			set_physics_process(false)
			$Sprite.play("Idle")
		STATES.AIM:
			play_sound("res://assets/sound/fx/hum", 1)
			set_physics_process(false)
		STATES.SHOOT:
			
#			if raycast.is_colliding():
#				hit_pos = raycast.get_collision_point()
#			else:
#				hit_pos = null
			
#			var overlapping_bodies = get_overlapping_bodies()
#			if not overlapping_bodies:
#				return
#			#if anim_player.current_animation_position >= 0.12:
#			#print_debug("test")
#			for body in overlapping_bodies:
#				print_debug(str(body))
#				if body.is_in_group("player"):
#					continue
#				#hit_pos = (body.global_position).rotated(rotation)
#				#raycast.global_position).rotated(-rotation)
			play_sound("res://assets/sound/fx/gun_charge", 3)
			set_physics_process(true)
			$Sprite.play("Shoot")
		STATES.COOLDOWN:
			if has_reflected:
				has_reflected = false
			if line.get_point_count() > 2:
				print_debug("point")
				line.remove_point(2)
			$Hitbox/Hitbox1.shape.b = Vector2(0, 0)
			$Hitbox/Hitbox8.shape.b = Vector2(0, 0)
			$Hitbox/Hitbox9.shape.b = Vector2(0, 0)
			$CDTimer.start()
			$Sprite.play("Reloading")
			
func _on_AnimationPlayer_animation_finished(anim_name):
	#line.visible = false
	if anim_name == get_parent().shoot_animation:
		#var post_shoot_effect = POST_SHOOT_EFFECT.instance()
		#add_child_below_node($Line2D, post_shoot_effect)
		#post_shoot_effect.set_point_position(0, $Line2D.get_point_position(0) + $Line2D.global_position)
		#post_shoot_effect.set_point_position(1, $Line2D.get_point_position(1) + hit_pos)
		#post_shoot_effect.get_node("AnimationPlayer").play("end")
		set_physics_process(false)
		_change_state(STATES.COOLDOWN)
		if hit_pos == null:
			hit_pos = (Vector2(4000, 0) + $Line2D.global_position).rotated(rotation)
		emit_signal("shoot_finished", $Line2D.global_position, hit_pos)
		$GunShootParticle.emitting = false
		line.visible = false
		$Light2D.visible = false
	#if anim_name == "end":
	#	line.visible = false
	#	anim_player.play("beam")
	#	anim_player.stop()

func _on_CDTimer_timeout():
	_change_state(STATES.IDLE)

func play_sound(path, amount_of_sounds):
#	if $SoundEffects.playing:
#		var asp = $SoundEffects.duplicate(DUPLICATE_USE_INSTANCING)
#		add_child(asp)
#		asp.stream = load(path + str(randi() % amount_of_sounds) + ".wav")
#		asp.pitch_scale = rand_range(0.90, 1.1)
#		asp.play()
#		yield(asp, "finished")
#		asp.queue_free()
#	else:
	$SoundEffects.stream = load(path + str(randi() % amount_of_sounds) + ".wav")
	$SoundEffects.pitch_scale = rand_range(0.90, 1.1)
	$SoundEffects.play()