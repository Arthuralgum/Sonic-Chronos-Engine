extends Node2D

@onready var SonicNode = $Player
var physics_state = gameplay_state.physics
enum gameplay_state {physics, wall_movement, combat_mode}
var EnemyPostitions: Array = []
var closestEnemy: Node
#var RailGlobalPosition = self.global_position

#Player elements
var CanHomeAttack: bool = false
var CouldHomeattack: bool = false

var CanRail: bool = false
var ExitedRail: bool = true

var CanLightDash: bool = false
var CanPressLightDash: bool = false
var ExitedLightDash: bool = false

var player_can_take_damage: bool = false
var player_take_damage: bool = false

#Score elements
var Rings: int = 0
var Score: int = 0
var Energy: float = 0.0
var total_time:float = 0.0
var Cutscene_ring: int = 0.0
var Cutscene_score: int = 0.0

#Physics elements
var null_head_stopper: bool = false
var GRAVITY: float = 980
var exit_wall_state: bool = false

var physics:bool = true
var wallmovment: bool = false
var combatmode: bool = false

#Physics objects
	#Springs
var SpringJumpForce: float
var IsSpringJumping: bool = false
var CanSpringJump: bool = false
var HasSpringJump: bool = false
signal spring_jump_motion(dash_force: Vector2)

	#Dash Panels
signal dash_panel_velocity(dash_force: Vector2)
signal  dash_pad_velocity(dash_force: Vector2)

	#Boost Rings
signal boost_ring_motion(dash_force: Vector2)
var exited_boost_ring: bool = false
var boost_ring: bool = false

	#Rails
var rails_positions: Array = []

#System

var is_cutscene: bool = false

var game_over: bool = false

var playable_char_path: String

var slected_level_path: String

var player_node
func _ready() -> void:
	pass
func _process(delta: float) -> void:
	get_closest_enemy(global_position)

func get_closest_enemy(pos: Vector2) -> Node2D:
	var distsq = 99999999999999999.0 # "infinity"
	closestEnemy = null
	if Global.game_over == true:
		return null
	for e in EnemyPostitions:
		var testd = pos.distance_squared_to(e.global_position)
		if testd < distsq:
			distsq = testd
			closestEnemy = e
	return closestEnemy

func register_rail_follow(follow: Node):
	if follow not in rails_positions:
		rails_positions.append(follow)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		Global.physics_state = Global.gameplay_state.wall_movement


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		Global.physics_state = Global.gameplay_state.physics
