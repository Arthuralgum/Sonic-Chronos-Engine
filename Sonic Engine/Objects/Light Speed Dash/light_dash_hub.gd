extends Path2D

var rails: Array = []
var rails_follow: Array = []
var last_rail: Node = null
var last_rail_follow: Node = null
var switch_distance_buffer := 50.0 # Adjust to taste
@onready var player:= $"../../Player"
var rail_path: Node
var rail_path_follow: Node
var exit_rail: bool = false
var rail_speed: float
var rotation_factor: float
var direction_factor: int = 1

func register_rail(rail: Node):
	if rail not in rails:
		rails.append(rail)
func register_rail_follow(follow: Node):
	if follow not in rails:
		rails_follow.append(follow)

func get_closest_rail(pos: Vector2) -> Node:
	if last_rail:
		var rail_sprite = last_rail.get_meta("aim")
		var current_dist = pos.distance_to(rail_sprite.global_position)
		if current_dist < switch_distance_buffer:
			return last_rail

	var closest = null
	var min_dist = INF
	for rail in rails:
		var sprite = rail.get_meta("aim")
		var dist = pos.distance_squared_to(sprite.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = rail

	last_rail = closest
	return closest
func get_closest_rail_follow(pos: Vector2) -> Node:
	if last_rail_follow:
		var rail_sprite = last_rail.get_meta("aim")
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
func _process(delta: float) -> void:
	rail_path = get_closest_rail(player.global_position)
	rail_path_follow = get_closest_rail_follow(player.global_position)
	rail_speed = rail_path_follow.rail_speed
	if !Global.CanRail:
		var local_player_pos = rail_path.to_local(player.global_position)
		var closest_offset = rail_path.curve.get_closest_offset(local_player_pos)
		rail_path_follow.progress = closest_offset

	# Only do full rail behavior once activated
	if Global.CanRail:
		player.control_lock = true
		player.is_spindashing_charging = false
		player.is_dropdash_charging = false
		player.spindash_released = false
		player.jumpcount = 0
		player.jumpsoundcount = 0
		Global.GRAVITY = 0
		rail_path_follow.v_offset = 0
		if player.last_facing_direction == Vector2.RIGHT:
			if rail_path_follow.rotation >= 0.5:
				rotation_factor = 1.5
			elif rail_path_follow.rotation <= -0.5:
				rotation_factor = 0.5
			else:
				rotation_factor = 1
			player.motion.x = 300
			rail_path_follow.progress += rail_speed
		elif player.last_facing_direction == Vector2.LEFT:
			if rail_path_follow.rotation >= 0.5:
				rotation_factor = 0.5
			elif rail_path_follow.rotation <= -0.5:
				rotation_factor = 1.5
			else:
				rotation_factor = 1
			direction_factor = -1
			player.motion.x = -300
			rail_path_follow.progress -= rail_speed * rotation_factor
		if (player.last_facing_direction == Vector2(-1.0, 0.0) and rail_path_follow.progress_ratio == 0) or (player.last_facing_direction == Vector2(1.0, 0.0) and rail_path_follow.progress_ratio == 1) or Input.is_action_just_pressed("jump"):
			exit_rail = true
			await get_tree().create_timer(0.1).timeout
			exit_rail = false
