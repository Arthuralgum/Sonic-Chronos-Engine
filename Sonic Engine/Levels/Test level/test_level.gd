extends Node2D
var loop_start_left: bool = false
var loop_start_right: bool = false
var loop_middle_point: bool = false
var is_down_path: bool = false
var is_up_path: bool = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var playable_character = Global.playable_char_path
	var player_node = load(playable_character).instantiate()
	add_child(player_node)
	player_node.global_position = $SpawnPoint.global_position
	Global.player_node = player_node
	_disable_left_loop()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
#------------------------------------------------------#
					#Level loops
	if loop_start_left:
		_disable_left_loop()
		_enable_right_loop()
	if loop_start_right:
		_disable_right_loop()
		_enable_left_loop()
	if loop_start_left and loop_middle_point:
		_enable_left_loop()
		_disable_right_loop()
	elif loop_start_right and loop_middle_point:
		_enable_right_loop()
		_disable_left_loop()
#------------------------------------------------------#
					#Up and down paths
	if is_up_path:
		_Enable_up_path()
		_Disable_down_path()
	elif is_down_path:
		_Enable_down_path()
		_Disable_up_path()
		
func _enable_left_loop()	-> void:
	$"Loops/Normal loop/Left Collision/CollisionPolygon2D".disabled = false
	$"Loops/Down loop/LeftCollision/CollisionPolygon2D".disabled = false
	

func _disable_right_loop() -> void:
	$"Loops/Normal loop/Right Collision/CollisionPolygon2D".disabled = true
	$"Loops/Down loop/RightCollision/CollisionPolygon2D".disabled = true
	

func _enable_right_loop() -> void:
	$"Loops/Normal loop/Right Collision/CollisionPolygon2D".disabled = false
	$"Loops/Down loop/RightCollision/CollisionPolygon2D".disabled = false
	

func _disable_left_loop() -> void:
	$"Loops/Normal loop/Left Collision/CollisionPolygon2D".disabled = true
	$"Loops/Down loop/LeftCollision/CollisionPolygon2D".disabled = true
	

func _Enable_up_path() -> void:
	$"Alternate Paths/Up Path/StaticBody2D/CollisionPolygon2D".disabled = false

func _Disable_up_path() -> void:
	$"Alternate Paths/Up Path/StaticBody2D/CollisionPolygon2D".disabled = true

func _Enable_down_path() -> void:
	$"Alternate Paths/Down Path/StaticBody2D/CollisionPolygon2D".disabled = false
	

func _Disable_down_path() -> void:
	$"Alternate Paths/Down Path/StaticBody2D/CollisionPolygon2D".disabled = true
	
#-----------------------Area Signals-------------------------#
func _on_left_to_right_body_entered(body: Player) -> void:
	print("Entered Left")
	loop_middle_point = false
	loop_start_left = true
	loop_start_right = false

func _on_middle_point_body_entered(body: Player) -> void:
	loop_middle_point = true


func _on_right_to_left_body_entered(body: Player) -> void:
	print("Entered Right")
	if loop_middle_point:
		_disable_left_loop()
	loop_middle_point = false
	loop_start_left = false
	loop_start_right = true

func _on_change_down_body_entered(body: Player) -> void:
	is_down_path = true
	is_up_path = false

func _on_change_up_body_entered(body: Player) -> void:
	is_down_path = false
	is_up_path = true


func _on_wall_body_entered(body: Player) -> void:
	Global.exit_wall_state = false
	Global.physics_state = Global.gameplay_state.wall_movement
	Global.GRAVITY = 0


func _on_wall_body_exited(body: Player) -> void:
	Global.exit_wall_state = true
	Global.GRAVITY = 0



func _on_combat_zone_body_entered(body: Player) -> void:
	Global.physics_state = Global.gameplay_state.combat_mode
	Global.GRAVITY = 0


func _on_combat_zone_body_exited(body: Player) -> void:
	Global.physics_state = Global.gameplay_state.physics
	Global.GRAVITY = 0
