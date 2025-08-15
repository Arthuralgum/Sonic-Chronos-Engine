extends Path2D

var dashes: Array = []
var dashes_follow: Array = []
var last_dash: Node = null
var last_dash_follow: Node = null
var switch_distance_buffer := 25.0 # Adjust to taste
var player 
var dash_path: Node
var dash_path_follow: Node
var exit_rail: bool = false
var rail_speed: float
var rotation_factor: float
var direction_factor: int = 1

func register_light_dash(dash: Node):
	if dash not in dashes:
		dashes.append(dash)
func register_light_dash_follow(follow: Node):
	if follow not in dashes_follow:
		dashes_follow.append(follow)
func get_closest_light_dash(pos: Vector2) -> Node:
	if last_dash:
		var dash_sprite = last_dash.get_meta("aim")
		var current_dist = pos.distance_to(dash_sprite.global_position)
		if current_dist < switch_distance_buffer:
			return last_dash

	var closest = null
	var min_dist = INF
	for dash in dashes:
		var sprite = dash.get_meta("aim")
		var dist = pos.distance_squared_to(sprite.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = dash

	last_dash = closest
	return closest
func get_closest_light_dash_follow(pos: Vector2) -> Node:
	if last_dash_follow and last_dash != null:
		var dash_sprite = last_dash.get_meta("aim")
		var current_dist = pos.distance_to(dash_sprite.global_position)
		if current_dist < switch_distance_buffer:
			return last_dash_follow

	var closest = null
	var min_dist = INF
	for follow in dashes_follow:
		var sprite = follow.get_meta("aim")
		var dist = pos.distance_squared_to(sprite.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = follow

	last_dash_follow = closest
	return closest
func _ready() -> void:
	player = Global.player_node
func _process(delta: float) -> void:
	player = Global.player_node
	if Global.game_over == false:
		dash_path = get_closest_light_dash(player.global_position)
		dash_path_follow = get_closest_light_dash_follow(player.global_position)
		if dash_path_follow != null:
			rail_speed = dash_path_follow.rail_speed
		if !Global.CanLightDash:
			if dash_path_follow != null and dash_path != null:
				var local_player_pos = dash_path.to_local(player.global_position)
				var closest_offset = dash_path.curve.get_closest_offset(local_player_pos)
				dash_path_follow.progress = closest_offset

		if Global.CanLightDash:
			player.motion.x = 0.0
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
			dash_path_follow.v_offset = 0
			dash_path_follow.progress += rail_speed
			if dash_path_follow.progress_ratio == 1:
				Global.ExitedLightDash = true
				dash_path_follow.activate_hitbox.disabled = true
				await get_tree().create_timer(0.1).timeout
				Global.ExitedLightDash = false
				dashes_follow.erase(dash_path_follow)
				dashes.erase(dash_path)
