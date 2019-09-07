extends Camera2D

var _duration = 0.0
var _period_in_ms = 0.0
var _amplitude = 0.0
var _timer = 0.0
var _last_shook_timer = 0
var _previous_x = 0.0
var _previous_y = 0.0
var _last_offset = Vector2(0, 0)

export(float, 0.0, 0.5) var zoom_offset : float = 0.2
export var debug_mode : bool = false

enum MODES {DEFAULT, ZOOM, MINI_ZOOM}

var camera_rect: = Rect2()
var viewport_rect: = Rect2()

var current_mode = null
var previous_mode = null
var winning_player
var focus
var old_zoom

func _ready():
	viewport_rect = get_viewport_rect()
	_change_mode(MODES.DEFAULT)
	#set_process(true)

# Shake with decreasing intensity while there's time remaining.
func _physics_process(delta: float):
	#if Input.is_action_just_pressed("ui_accept"):
#		if current_mode == MODES.DEFAULT:
#			_change_mode(MODES.ZOOM)
#		elif current_mode == MODES.ZOOM:
#			_change_mode(MODES.DEFAULT)
	match current_mode:
		MODES.DEFAULT:
			#print_debug("test")
			#camera_rect = Rect2(get_child(0).global_position, Vector2())
#			for index in get_child_count():
#				if index == 0:
#					continue
			#camera_rect = camera_rect.expand(get_child(1).global_position)
		
#			offset = lerp(offset, calculate_center(camera_rect), 0.1)
#			zoom = lerp(zoom, calculate_zoom(camera_rect, viewport_rect.size), 0.2)
			
			#offset = lerp(offset, (get_child(0).global_position + get_child(1).global_position) * 0.5, 0.2)
			
			#print_debug("width: " + str(width) + " height: " + str(height))
			
			
			var width = abs(get_child(0).global_position.x - get_child(1).global_position.x)
			var height = abs(get_child(0).global_position.y - get_child(1).global_position.y)
			
			#(offset.x+(width/2) >= limit_right) and 
			# and ((offset.x-(width/2)) <= limit_left)
			#print_debug(str(((offset.x-(width/2)))))
			if !(get_child(0).current_state == get_child(0).STATES.DYING or get_child(1).current_state == get_child(1).STATES.DYING):
				offset = lerp(offset, (get_child(0).global_position + get_child(1).global_position) * 0.5, 0.2)
			
			if (((width/2) <= 520) and (height/2) <= 270):
				
				
				#print_debug(str(offset.x+(width/2)))
				var max_zoom = max(
					max(.7, width / viewport_rect.size.x + zoom_offset),
					max(.7, height / viewport_rect.size.y + zoom_offset))
				
				zoom = lerp(zoom, Vector2(max_zoom, max_zoom), 0.2)

			
			#zoom = Vector2(width, height)
			
			if debug_mode:
				update()
				print_debug("x: " + String(clamp(camera_rect.size.x, -672, 672)) + " y: " + String(clamp(camera_rect.size.y, -450, 450)))
		MODES.ZOOM:
			offset = winning_player.global_position#lerp(offset, winning_player.global_position, 0.1)
			offset.x = offset.x+5
			zoom = lerp(zoom, Vector2(0.3, 0.3), 0.5)
		MODES.MINI_ZOOM:
			#offset = focus.global_position#lerp(offset, winning_player.global_position, 0.1)
			#offset.x = offset.x+5
			zoom = lerp(zoom, old_zoom - Vector2(0.1, 0.1), 0.3)
			
	##################################################################################

	# Only shake when there's shake time remaining.
	if _timer == 0:
		return
	# Only shake on certain frames.
	_last_shook_timer = _last_shook_timer + delta
	# Be mathematically correct in the face of lag; usually only happens once.
	while _last_shook_timer >= _period_in_ms:
		_last_shook_timer = _last_shook_timer - _period_in_ms
		# Lerp between [amplitude] and 0.0 intensity based on remaining shake time.
		var intensity = _amplitude * (1 - ((_duration - _timer) / _duration))
		# Noise calculation logic from http://jonny.morrill.me/blog/view/14
		var new_x = rand_range(-1.0, 1.0)
		var x_component = intensity * (_previous_x + (delta * (new_x - _previous_x)))
		var new_y = rand_range(-1.0, 1.0)
		var y_component = intensity * (_previous_y + (delta * (new_y - _previous_y)))
		_previous_x = new_x
		_previous_y = new_y
		# Track how much we've moved the offset, as opposed to other effects.
		var new_offset = Vector2(x_component, y_component)
		set_offset(get_offset() - _last_offset + new_offset)
		_last_offset = new_offset
	# Reset the offset when we're done shaking.
	_timer = _timer - delta
	if _timer <= 0:
		_timer = 0
		set_offset(get_offset() - _last_offset)

	##################################################################################

# Kick off a new screenshake effect.
func shake(duration, frequency, amplitude):
	# Initialize variables.
	_duration = duration
	_timer = duration
	_period_in_ms = 1.0 / frequency
	_amplitude = amplitude
	_previous_x = rand_range(-1.0, 1.0)
	_previous_y = rand_range(-1.0, 1.0)
	# Reset previous offset, if any.
	set_offset(get_offset() - _last_offset)
	_last_offset = Vector2(0, 0)

func calculate_center(rect: Rect2) -> Vector2:
	return Vector2(
		clamp(rect.position.x, -672, 672) + clamp(rect.size.x, 0, 1000) / 2,
		clamp(rect.position.y, -608, 608) + clamp(rect.size.y, 0, 500) / 2)
		

func calculate_zoom(rect: Rect2, viewport_size: Vector2) -> Vector2:
	var max_zoom = max(
		max(1, clamp(rect.size.x, 0, 1000) / viewport_size.x + zoom_offset),
		max(1, clamp(rect.size.y, 0, 500) / viewport_size.y + zoom_offset))
		#max(1, rect.size.x / viewport_size.x + zoom_offset),
		#max(1, rect.size.y / viewport_size.y + zoom_offset))
		#max(1, rect.size.y / viewport_size.y + zoom_offset))
		#max(1, clamp(rect.size.y, 0, 2000) / viewport_size.y + zoom_offset))
		#max(1, rect.size.x / clamp(viewport_size.x, -675, 675) + zoom_offset),
		#max(1, rect.size.y / clamp(viewport_size.y, -450, 450) + zoom_offset))
		#max(1, clamp(rect.size.x / viewport_size.x + zoom_offset, -675, 675)),
		#max(1, clamp(rect.size.y / viewport_size.y + zoom_offset, -450, 450)))
	return Vector2(max_zoom, max_zoom)

func _draw():
	if not debug_mode:
		return
	draw_rect(camera_rect, Color("#ffffff"), false)
	draw_circle(calculate_center(camera_rect), 5, Color("#ffffff"))
	
func _change_mode(new_mode):
	previous_mode = current_mode
	current_mode = new_mode
	
	match new_mode:
		MODES.MINI_ZOOM:
			old_zoom = zoom

func _on_Player_player_win(player):
	change_mode_zoom(player)

func change_mode_zoom(player):
	winning_player = player
	_change_mode(MODES.ZOOM)
	
func change_mode_mini_zoom(player):
	focus = player
	_change_mode(MODES.MINI_ZOOM)
	
func _on_Player_focus_player(player):
	change_mode_zoom(player)

func mini_zoom():
	zoom = lerp(zoom, Vector2(0.9, 0.9), 0.05)

#func _on_Player1_player_dead(score):
#	hit_zoom()
#
#func _on_Player2_player_dead(score):
#	hit_zoom()
#
#func hit_zoom():
#	zoom = Vector2(0.7, 0.7)
#
