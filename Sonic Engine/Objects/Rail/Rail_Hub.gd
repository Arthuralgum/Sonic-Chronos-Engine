extends Path2D

var rails_follow: Array = []
var last_rail_follow: Node = null
var switch_distance_buffer := 20.0 # Adjust to taste
var player 
var rail_path_follow: Node
var exit_rail: bool = false
var rail_speed: float
var rotation_factor: float
var rail_velocity := 0.0

func register_rail_follow(follow: Node):
	if follow not in rails_follow:
		rails_follow.append(follow)

func get_closest_rail_follow(pos: Vector2) -> Node:
	if last_rail_follow:
		var rail_sprite = last_rail_follow.get_meta("aim")
		var current_dist = pos.distance_to(rail_sprite.global_position)
		if current_dist < switch_distance_buffer:
			return last_rail_follow

	var closest = null
	var min_dist = INF
	for follow in rails_follow:
		var sprite = follow.get_meta("aim")
		var dist = pos.distance_squared_to(sprite.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = follow
	last_rail_follow = closest
	return closest
	
func reset_player_congfig():
	player.control_lock = true
	player.facing_direction_lock = true
	player.is_spindashing_charging = false
	player.is_dropdash_charging = false
	player.spindash_released = false
	player.jumpcount = 0
	player.jumping = false
	player.bouncing_state = false
	player.bounced = false
	player.jumpsoundcount = 0
	Global.boost_ring = false
	Global.GRAVITY = 0
	rail_path_follow.v_offset = 0

func player_exit_motion():
	player.facing_direction_lock = true
	var rotation_factor: int = 1
	if player.last_facing_direction == Vector2.RIGHT:
		if rotation < PI/2:
			player.motion = Vector2(rail_velocity,0.0).rotated(rail_path_follow.rotation)
		else:
			player.motion = Vector2(-rail_velocity,0.0).rotated(rail_path_follow.rotation)
	else:
		if rotation < PI/2:
			player.motion = Vector2(-rail_velocity,0.0).rotated(rail_path_follow.rotation)
		else:
			player.motion = Vector2(rail_velocity,0.0).rotated(rail_path_follow.rotation)
	print(rail_path_follow.rotation)
func apply_rail_motion(delta: float):
	if Global.ExitedRail:
		return
	var slope_angle = rail_path_follow.rotation
	var gravity_force = 500.0
	var acceleration = gravity_force * sin(slope_angle)
	var player_motion: float
	rail_velocity = clamp(rail_velocity,750, 2000)
	if abs(player.motion.x) >= abs(player.motion.y):
		player_motion = abs(player.motion.x)
	else:
		player_motion = abs(player.motion.y)
	if (acceleration >= 0 and player.last_facing_direction == Vector2.RIGHT) or (acceleration < 0 and player.last_facing_direction == Vector2.LEFT):
		acceleration = clamp(acceleration,200.0,500.0)
	elif (acceleration < 0 and player.last_facing_direction == Vector2.RIGHT) or (acceleration >= 0 and player.last_facing_direction == Vector2.LEFT):
		acceleration = clamp(acceleration,-100.0,-50.0)
	player_motion += acceleration/10
	rail_velocity = (acceleration + player_motion)
	if player.last_facing_direction == Vector2.RIGHT:
		rail_path_follow.progress += rail_velocity * delta
	elif player.last_facing_direction == Vector2.LEFT:
		rail_path_follow.progress -= rail_velocity * delta

func _process(delta: float) -> void:
	player = Global.player_node
	if Global.game_over == false:
		rail_path_follow = get_closest_rail_follow(player.global_position)
		rail_speed = rail_path_follow.rail_speed
		for follow in rails_follow:
			var rail = follow.get_parent()
			if rail and rail is Path2D:
				var local_player_pos = rail.to_local(player.global_position)
				var closest_offset = rail.curve.get_closest_offset(local_player_pos)
				follow.progress = closest_offset
		if Global.CanRail:
			reset_player_congfig()
			if !Global.ExitedRail:
				apply_rail_motion(delta)
			if (player.last_facing_direction == Vector2.LEFT and rail_path_follow.progress_ratio == 0) or (player.last_facing_direction == Vector2.RIGHT and rail_path_follow.progress_ratio == 1.0) or Input.is_action_just_pressed("jump"):
				print(Global.CanRail)
				Global.ExitedRail = true
				player_exit_motion()
				await get_tree().create_timer(0.20).timeout
				Global.ExitedRail = false
			
