extends KinematicBody2D

const UP = Vector2(0, -1)
var GRAVITY = 20
const MAX_FALL_SPEED = 500
const WALL_SLIDE_SPEED = 10
var ACCELERATION = 30
var MAX_SPEED = 300
var MAX_DASH_SPEED = 1500
const JUMP_HEIGHT = 400
const AMOUNT_OF_JUMPS = 2
const AMOUNT_OF_DASHES = 2
const AMOUNT_OF_ATTACKS = 1
const DEAD_BODY = preload("res://scenes/DeadBody.tscn")
const DUST_PARTICLE = preload("res://scenes/DustParticle.tscn")
const SPAWN_PARTICLE = preload("res://scenes/SpawnParticle.tscn")
const SLASH = preload("res://scenes/Slash.tscn")
const EXPLOSION_EFFECT = preload("res://scenes/Explosion.tscn")
const KNOCKBACK = 60
const IDLE_ANIM_NUM = 2
const MAX_IFRAMES = 2.0
const MAX_SCORE = 5
const DEAD_ZONE = .5

var times_jumped = 0
var times_dashed = 0
var times_attacked = 0
var motion = Vector2()
var motion_input = Vector2()
var dashing = false
var falling = false
var can_attack = true
var hit_wall = false
var explosion_effect
var blast_direction = Vector2(0, 0)
var times_hit_wall
var player_won = false
var start_attack = false
var start_attack_lunge = false
var has_reflected = false
var blast_dir_move
var gun_dir = Vector2(-200, 0)
var sword_cd = false

var jump_path = "res://assets/sound/fx/jump"
var land_path = "res://assets/sound/fx/land"
var hitsound_path = "res://assets/sound/fx/hitsound"

var score = 0

enum STATES {WALK, DASH, SHOOT, STARTUP, ATTACK, DYING, DEAD}
var current_state = null
var previous_state = null

var facing_right
var respawn_point
var invincible
var iframes

onready var camera = get_parent()
onready var audio = $SoundEffects
onready var collider = $CollisionShape2D

signal player_dead
signal hit_effect_start
signal hit_effect_over
signal start_attack
signal end_attack
signal player_win(player)
signal focus_player(player)
signal player_suicide

export(int) var player_num = 1
export(String) var jump_input = "jump"
export(String) var attack_input = "attack"
export(String) var move_right_input = "move_right"
export(String) var move_up_input = "move_up"
export(String) var move_left_input = "move_left"
export(String) var move_down_input = "move_down"
export(String) var dash_input = "dash"
export(String) var shoot_input = "shoot"
export(String) var shoot_animation = "beam"

var character_name = "Default"
var attack_buffer = 0
#var life_icon = load("res://ui/toast_score_icon_filled.png")

##########################################################################

func _ready():
	#$Reflect/ReflectHitbox.disabled = false
	blast_dir_move = Vector2(-2000, 0)
	$IdleTimer.stop()
	set_physics_process(false)
	invincible = false
	iframes = MAX_IFRAMES
	facing_right = true
	add_to_group("player")
	$TrailParticle.emitting = false
	$TrailLine.visible = false
	_change_state(STATES.WALK)

##########################################################################

func _physics_process(delta):
	if invincible:
		iframes-=delta
	if iframes <= 0.0:
		invincible = false
		iframes = MAX_IFRAMES
	
	global_position.x = clamp(global_position.x, -672, 672)
	global_position.y = clamp(global_position.y, -608, 608)
	
	if global_position.y <= -608 or global_position.y >= 608:
		#print_debug("test")
		#motion.x = -motion.x
		#motion.y = -motion.y
		motion = motion.bounce(motion.normalized())
	if global_position.x <= -672 or global_position.x >= 672:
		#print_debug("test")
		#motion.x = -motion.x
		#motion.y = -motion.y
		motion = motion.bounce(motion.normalized())
		
	if score >= MAX_SCORE and !player_won:
		$DeathTimer.start()
		player_won = true
	if $DeathTimer.time_left < 0.1 and player_won and $DeathTimer.time_left > 0:
		#player_won = false
		yield(get_tree().create_timer(0.5), "timeout" )
		emit_signal("player_win", self)
		
	
	if Input.is_action_pressed(move_left_input):
		motion_input.x = -1
	elif Input.is_action_pressed(move_right_input):
		motion_input.x = 1
	elif motion_input.y != 0:
		motion_input.x = 0
	
	if Input.is_action_pressed(move_up_input):
		motion_input.y = -1
	elif Input.is_action_pressed(move_down_input):
		motion_input.y = 1
	elif motion_input.x != 0:
		motion_input.y = 0
	
	match current_state:
		STATES.WALK:
			# behaviors
			#$Reflect/ReflectHitbox.disabled = true
			
			### IDLE ANIM
			if is_on_floor() and !is_on_wall() and motion.x == 0:
				if !($Sprite.animation == "IdleAnim0" or $Sprite.animation == "IdleAnim1"):
					$Sprite.play("Idle")
					if $IdleTimer.is_stopped():
						$IdleTimer.start()
			else:
				$IdleTimer.stop()
			
			### JUMPING
			if is_on_floor() or times_jumped < AMOUNT_OF_JUMPS-1:
				if Input.is_action_just_pressed(jump_input):
					dust_particle()
					motion.y = -JUMP_HEIGHT
					times_jumped+=1
					play_sound(jump_path, 3)
				if Input.is_action_just_released(jump_input) and motion.y < 0:
					motion.y = lerp(motion.y, 0, 0.4)
				
			var friction = false
			
			### MOVING
			if Input.is_action_pressed(move_right_input):
				motion.x = min(motion.x+ACCELERATION, MAX_SPEED)
				
				#var right = Input.get_action_strength(move_right_input)
				#motion.x = min(motion.x + (right * ACCELERATION), MAX_SPEED - (right * ACCELERATION))
				
				#motion.x = min(motion.x+(Input.get_action_strength(move_right_input)), MAX_SPEED)
				#get_node("Sword/AnimatedSprite").flip_v = false
				#get_node("Sword").set_rotation_degrees(0)
				if !is_on_wall():
					$Sprite.flip_h = !facing_right
					$Sprite.play("Run")
			elif Input.is_action_pressed(move_left_input):
				motion.x = max(motion.x-ACCELERATION, -MAX_SPEED)
				
				#var left = Input.get_action_strength(move_right_input)
				#motion.x = min(motion.x - (left * ACCELERATION), -MAX_SPEED + (left * ACCELERATION))
				#get_node("Sword/AnimatedSprite").flip_v = true
				#get_node("Sword").set_rotation_degrees(180)
				if !is_on_wall():
					$Sprite.flip_h = facing_right
					$Sprite.play("Run")
			else:
				if $Sprite.animation == "Run":
					$Sprite.play("Idle")
				friction = true

			if is_on_floor():
				if friction:
					motion.x = lerp(motion.x, 0, 0.3)
				times_jumped = 0
				times_dashed = 0
				times_attacked = 0
			else: ############ CAN BE SIMPLIFIED SEE BELOW
				if motion.y < 0:
					if !is_on_wall():
						#falling = true
						$Sprite.play("Jump")
				else:
					if !is_on_wall():
						$Sprite.play("Fall")
				if friction:
					motion.x = lerp(motion.x, 0, 0.05)
				
#			if motion.y < 0: ## JUMPING
#				if !is_on_wall():
#					$Sprite.play("Jump")
#
			
#					$Sprite.play("Fall")
#					in_idle = false
#				if Input.is_action_pressed(move_down_input):
#					$Sprite.play("SuperFall")
#				if friction:
#					motion.x = lerp(motion.x, 0, 0.05)

			if is_on_floor() and falling:
				dust_particle()
				play_sound(land_path, 4)
				falling = false
				$Sprite.play("Squash")
				
			if motion.y > GRAVITY:
				if !is_on_wall():
					#print_debug("landing")
					falling = true
			
			if is_on_floor() and Input.is_action_pressed(move_down_input) and motion_input.x == 0:
				$Sprite.play("Squash")
			elif is_on_floor() and Input.is_action_just_released(move_down_input):
				$Sprite.play("Idle")
				
			if is_on_floor() and (Input.is_action_just_pressed(move_right_input) or Input.is_action_just_pressed(move_left_input)):
				dust_particle()
				
			### AIMING
			if Input.is_action_pressed(shoot_input):
				var look_dir = Vector2(Input.get_joy_axis(player_num-1, JOY_AXIS_0), Input.get_joy_axis(player_num-1, JOY_AXIS_1))
				#get_node("Gun").aim(motion_input)
				#print_debug(str(look_dir))
				if look_dir.length() >= DEAD_ZONE:
					get_node("Gun").aim(look_dir)
				
			
			### ATTACKING
#			if Input.is_action_just_pressed(attack_input):
#				if can_attack:
#					$Gun/Sprite.visible = false
#					can_attack = false
#					audio.stream = load("res://hit_effect.wav")
#					audio.play()
#					camera.shake(.1, 15, 8)
#					get_node("Sword").attack()
			
#			if (get_node("Sword").visible == true):
#				get_node("Sword").rotate(motion_input)
				
			var look_dir = Vector2(Input.get_joy_axis(player_num-1, JOY_AXIS_0), Input.get_joy_axis(player_num-1, JOY_AXIS_1))
			#print(str(look_dir))
			if look_dir.length() >= DEAD_ZONE:
				get_node("Gun").rotate(look_dir)
				gun_dir = look_dir
				
			motion = move_and_slide(motion, UP)
			
			if is_on_wall():
				if !hit_wall:
					$Sprite.flip_h = !$Sprite.flip_h
					$Sprite.play("WallSlide")
					hit_wall = true
				if motion.y < MAX_FALL_SPEED/8:
					motion.y += GRAVITY
				else:
					motion.y = MAX_FALL_SPEED/8
				if Input.is_action_just_pressed(jump_input):
					dust_particle()
					motion.x = -motion_input.x*MAX_SPEED
					motion.y = -JUMP_HEIGHT
					times_jumped+=1
					play_sound(jump_path, 3)
			elif motion.y < MAX_FALL_SPEED*2 and Input.is_action_pressed(move_down_input) and (motion_input.x == 0) and !is_on_floor():
				motion.y+=GRAVITY*2
				$Sprite.play("SuperFall")
			elif motion.y < MAX_FALL_SPEED:
				motion.y += GRAVITY
				
			if !is_on_wall():
				hit_wall = false
				
				

				
			#if abs(motion.x) >= MAX_SPEED/2 or abs(motion.y) >= MAX_SPEED/2:
#			if is_on_wall():
#				print_debug("hit")
#				motion.x = -motion.x
#				motion.y = -motion.y
			
			# transition triggers
			if is_on_floor() or times_dashed < AMOUNT_OF_DASHES:
				if Input.is_action_just_pressed(dash_input):
					times_dashed+=1
					play_sound("res://assets/sound/fx/dash", 1)
					_change_state(STATES.DASH)
			if Input.is_action_just_released(shoot_input):
				if $Gun.current_state != $Gun.STATES.COOLDOWN:
					_change_state(STATES.SHOOT)
			if (is_on_floor() or times_attacked < AMOUNT_OF_ATTACKS) and !sword_cd:
				if Input.is_action_just_pressed(attack_input) or attack_buffer > 0:
					attack_buffer = 0
					times_attacked+=1
					_change_state(STATES.ATTACK)
				
		STATES.DASH:
			# behaviors
			$TrailParticle.emitting = true
			$TrailLine.visible = true
#			if Input.is_action_pressed(move_up_input):
#				motion.y = -MAX_DASH_SPEED
#			if Input.is_action_pressed(move_down_input):
#				motion.y = MAX_DASH_SPEED
#			if Input.is_action_pressed(move_left_input):
#				motion.x = -MAX_DASH_SPEED
#			if Input.is_action_pressed(move_right_input):
#				motion.x = MAX_DASH_SPEED
				
			var look_dir = Vector2(Input.get_joy_axis(player_num-1, 0), Input.get_joy_axis(player_num-1, 1))
				
			if look_dir.length() >= .2:
				motion = look_dir * MAX_DASH_SPEED
			else:
				motion = motion_input * MAX_DASH_SPEED
				
			motion = move_and_slide(motion, UP)
			
			# transition triggers
			#### DASH TIMER END -> MOVE STATE
			attack_buffer()
				
			# sprites
			$Sprite.play("Squash")
		
		STATES.SHOOT:
			# behaviors
			#var dir = global_position - global_position+(-blast_direction*10) #$Gun/Position2D.global_position
			if blast_direction.length() >= DEAD_ZONE:
				blast_dir_move = -blast_direction*10
			else:
				blast_dir_move = -gun_dir*10
			motion.x += clamp(blast_dir_move.x * 20, -40, 40) #lerp(6, 1, .9)
			motion.y += clamp(blast_dir_move.y * 20, -40, 40)
			#camera.shake(.1, 15, 8)
			
			#motion += dir / 10
			
			motion = move_and_slide(motion, UP)
			
			# transition triggers
			#### SHOOT TIMER END -> MOVE STATE
			attack_buffer()
				
			# sprites
			$Sprite.play("Idle")
			
		STATES.ATTACK:
#			if !start_attack:
#				var look_dir = Vector2(Input.get_joy_axis(player_num-1, 0), Input.get_joy_axis(player_num-1, 1))
#				motion = look_dir * MAX_DASH_SPEED

			var look_dir = Vector2(Input.get_joy_axis(player_num-1, 0), Input.get_joy_axis(player_num-1, 1))

			if start_attack and !start_attack_lunge:
				if $Arrow.visible == false:
					emit_signal("start_attack")
				$Arrow.visible = true
				if look_dir.length() >= DEAD_ZONE:
					$Arrow.rotation = look_dir.angle()
			
			var button_released = Input.is_action_just_released(attack_input)
			
			if !start_attack_lunge and button_released:
				emit_signal("end_attack")
				get_node("Sword").rotate(look_dir)
				$AttackStartTimer.start()
				$Sprite/AnimationPlayer.play("attack")
				start_attack_lunge = true
				look_dir = Vector2(Input.get_joy_axis(player_num-1, 0), Input.get_joy_axis(player_num-1, 1))
				if look_dir.length() >= .2:
					motion = look_dir * MAX_DASH_SPEED
				else:
					motion = motion_input * MAX_DASH_SPEED
				
			if start_attack_lunge:
				$Arrow.visible = false
				motion = move_and_slide(motion, UP)
			
		STATES.DYING:
			# behaviors
			move_and_slide(motion, UP)
			if is_on_wall():
				play_sound("res://assets/sound/fx/body_hit_wall", 1)
#				motion.x = -motion.x/2
#				motion.y = -motion.y/2
				motion.bounce(motion.normalized())
				times_hit_wall+=1
			# transition triggers
			if times_hit_wall >= 3:
				_change_state(STATES.DEAD)
				
			# sprites
			$Sprite.play("Idle")

##########################################################################

func _change_state(new_state):
	previous_state = current_state
	current_state = new_state
	
	# initialize/enter the state
	match new_state:
		STATES.WALK:
			pass
		STATES.DASH:
			camera.mini_zoom()
			motion.x = 0
			motion.y = 0
			$DashTimer.start()
		STATES.SHOOT:
			motion.x = 0
			motion.y = 0
			#blast_direction = motion_input
			blast_direction = Vector2(Input.get_joy_axis(player_num-1, JOY_AXIS_0), Input.get_joy_axis(player_num-1, JOY_AXIS_1))
			#blast_direction = $Gun.
			camera.shake(.4, 15, 25)
			#camera.shake(.1, 15, 50)
			get_node("Gun").shoot(motion_input)
		STATES.ATTACK:
			$Gun.visible = false
			$AttackTimer.start()
			#camera.change_mode_mini_zoom(self)
		STATES.DYING:
			times_hit_wall = 0
			invincible = true
			$DeathTimer.start()
		STATES.DEAD: 
			play_sound("res://assets/sound/fx/explosion", 1)
			explosion()
			set_position(get_parent().get_parent().get_node(respawn_point).position)
			spawn_particle()
			invincible = true
			$Sprite/AnimationPlayer.play("inv")
			motion.x = 0
			motion.y = 0
			_change_state(STATES.WALK)

##########################################################################

func _on_DashTimer_timeout():
	if motion.x < 0:
		motion.x = -MAX_SPEED
	if motion.x > 0:
		motion.x = MAX_SPEED
	if motion.y < 0:
		motion.y = -MAX_SPEED
	if motion.y > 0:
		motion.y = MAX_SPEED
	$TrailParticle.emitting = false
	$TrailLine.visible = false
	if current_state != STATES.DYING or current_state != STATES.DEAD:
		_change_state(STATES.WALK)
	
func _on_Gun_shoot_finished(point1, point2):
	#motion.x = 0
	#motion.y = 0
	times_dashed = 0
	times_jumped = 0
	times_attacked = 0
	if current_state != STATES.DYING or current_state != STATES.DEAD:
		_change_state(STATES.WALK)
	
	#post_shoot_effect
	
func _on_Sword_attack_finished():
	#can_attack = true
#	if motion.x < 0:
#		motion.x = -MAX_SPEED
#	if motion.x > 0:
#		motion.x = MAX_SPEED
#	if motion.y < 0:
#		motion.y = -MAX_SPEED
#	if motion.y > 0:
#		motion.y = MAX_SPEED
#	start_attack = false
#	start_attack_lunge = false
#	camera._change_mode(camera.MODES.DEFAULT)
#	$Gun.visible = true
#	if current_state != STATES.DYING or current_state != STATES.DEAD:
#		_change_state(STATES.WALK)
	pass
	
func _on_DeathTimer_timeout():
	if current_state == STATES.DYING:
		_change_state(STATES.DEAD)
	
func _on_Sprite_animation_finished():
	if $Sprite.get_animation() == "Squash" and !Input.is_action_pressed(move_down_input):
		$Sprite.play("Idle")
	if $Sprite.get_animation() == "IdleAnim0" or $Sprite.get_animation() == "IdleAnim1":
		$Sprite.play("Idle")
	if $Sprite.get_animation() == "Spawnin":
		$Sprite.play("Idle")

##########################################################################

func hit():
	#camera.shake(.1, 15, 8)

	play_sound(hitsound_path, 3)
	freeze()
	show_slash()
	camera.mini_zoom()
	if current_state != STATES.DYING:
		_change_state(STATES.DYING)
		
func knockback(body, amount):
	var dir = transform.origin - body.transform.origin
	motion = dir * amount
	
func dust_particle():
	var dust_particle = DUST_PARTICLE.instance()
	get_parent().add_child(dust_particle)
	dust_particle.set_position(self.get_position())
	dust_particle.position.y += 15
	dust_particle.position.x += 5
	
func spawn_particle():
	var spawn_particle = SPAWN_PARTICLE.instance()
	get_parent().add_child(spawn_particle)
	spawn_particle.set_position(self.get_position())
	spawn_particle.position.y += 15
	
func explosion():
	var explosion_effect = EXPLOSION_EFFECT.instance()
	camera.shake(.3, 15, 25)
	get_parent().add_child(explosion_effect)
	explosion_effect.set_position(self.get_position())
#	explosion_effect.play("default")
#	yield(get_tree().create_timer(1.0), 'timeout')
#	explosion_effect.queue_free()
	
func freeze():
	var freeze_time = 0.3
	if score >= MAX_SCORE:
		freeze_time = 2.0
	get_tree().paused = true
	yield(get_tree().create_timer(freeze_time), 'timeout')
	get_tree().paused = false

	$Sprite.modulate = Color(1, 1, 1)
	$Sprite.z_index = 0
	emit_signal("hit_effect_over")
	
func is_dead():
	return current_state == STATES.DEAD
	
func show_slash():
	var slash = SLASH.instance()
	get_parent().add_child(slash)
	slash.set_position(self.get_position())
	
	$Sprite.modulate = Color(0, 0, 0)
	$Sprite.z_index = 2
	emit_signal("hit_effect_start")

func _on_Sword_killed_player():
	if score < MAX_SCORE:
		score += 1
		emit_signal("player_dead", score)

func _on_Gun_killed_player():
	if score < MAX_SCORE:
		score += 1
		emit_signal("player_dead", score)
		
func kill():
	_change_state(STATES.DEAD)
	emit_signal("player_suicide")

func focus_player():
	emit_signal("focus_player", self)
	$Sprite.play("Spawnin")
	
func enable_process():
	print_debug("test")
	set_physics_process(true)

func _on_AttackTimer_timeout():
	start_attack = true

func _on_AttackStartTimer_timeout():
	$SwordCD.start()
	sword_cd = true
	if motion.x < 0:
		motion.x = -MAX_SPEED
	if motion.x > 0:
		motion.x = MAX_SPEED
	if motion.y < 0:
		motion.y = -MAX_SPEED
	if motion.y > 0:
		motion.y = MAX_SPEED
	start_attack = false
	start_attack_lunge = false
	camera._change_mode(camera.MODES.DEFAULT)
	$Gun.visible = true
	if current_state != STATES.DYING or current_state != STATES.DEAD:
		_change_state(STATES.WALK)
	
	
func reflected():
	#print_debug(name + " reflected")
	invincible = true
	yield(get_tree().create_timer(1), "timeout" )
	invincible = false
	
func play_sound(path, amount_of_sounds):
	if $SoundEffects.playing:
		var asp = $SoundEffects.duplicate(DUPLICATE_USE_INSTANCING)
		add_child(asp)
		asp.stream = load(path + str(randi() % amount_of_sounds) + ".wav")
		asp.pitch_scale = rand_range(0.90, 1.1)
		asp.play()
		yield(asp, "finished")
		asp.queue_free()
	else:
		$SoundEffects.stream = load(path + str(randi() % amount_of_sounds) + ".wav")
		$SoundEffects.pitch_scale = rand_range(0.90, 1.1)
		$SoundEffects.play()
	
func _on_IdleTimer_timeout():
	$Sprite.play("IdleAnim" + str(randi() % IDLE_ANIM_NUM))
	
func attack_buffer():
	if Input.is_action_just_pressed(attack_input):
		attack_buffer = 5
	elif attack_buffer > 0:
		attack_buffer-=1


func _on_Player1_player_suicide():
	if player_num == 2:
		if score < MAX_SCORE:
			score += 1
			emit_signal("player_dead", score)
		
func _on_Player2_player_suicide():
	if player_num == 1:
		if score < MAX_SCORE:
			score += 1
			emit_signal("player_dead", score)

func _on_SwordCD_timeout():
	sword_cd = false
	attack_buffer()
