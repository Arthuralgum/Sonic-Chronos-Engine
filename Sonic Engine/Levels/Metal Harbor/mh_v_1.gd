extends Node2D
var loop_start_left: bool = false
var loop_start_right: bool = false
var loop_middle_point: bool = false
var is_down_path: bool = false
var is_up_path: bool = true
var player_node
var paused := false
@onready var pause_menu: CanvasLayer = $Camera2D/PauseMenu


@export var intro_anim: Control

func _ready() -> void:
	var playable_character = Global.playable_char_path
	player_node = load(playable_character).instantiate()
	##If you see the error: "Attempt to call function 'instantiate' in base 'null instance' on a null instance."
	#It can mean multiple things, but here is the main one:
	#This level gets the character node from the Character Selection Screen Scene.
	#So if you tried to only load this scene and not the project (or if for some reason
	#the character selection scene didn't load) then the variable: 
	#Global.playable_char_path has not been initialized
	
	##How do i fix it?
	#There are multiple ways: First (obviously) try to go through the
	#Character Selection Screen Scene before entering this level. 
	#If you want to load this scene exclusively, add the character that
	#you want, and atritubute it to the Global.playable_char_path variable
	#So the first line in this (_ready()) function should be:
	#Global.playable_char_path = $YOUR_HARACTER_NODE_PATH
	#And Then:
	#var playable_character = Global.playable_char_path
	#I hope this helped :)
	
	add_child(player_node)
	player_node.global_position = $SpawnPoint.global_position
	Global.player_node = player_node
	Global.game_over = false
	$Camera2D.make_current()
	_disable_left_loop()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !intro_anim.intro_finished:
		player_node.motion = Vector2(0.0,0.0)
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
	$"Collisions/Loops/Loop 11/LeftCollision/CollisionPolygon2D".disabled = false
	$Collisions/Loops/Loop1/LeftCollision/CollisionPolygon2D.disabled = false
	$"Collisions/Start 1/Loop2/LeftCollision/CollisionPolygon2D".disabled = false
	$Collisions/Loops/Loop3/LeftCollision/CollisionPolygon2D.disabled = false
	$Collisions/Loops/Loop4/LeftCollision/CollisionPolygon2D.disabled = false
	$Collisions/Loops/Loop5/LeftCollision/CollisionPolygon2D.disabled = false
	$Collisions/Loops/Loop6/LeftCollision/CollisionPolygon2D.disabled = false
	$Collisions/Loops/Loop7/LeftCollision/CollisionPolygon2D.disabled = false
	$Collisions/Loops/Loop8/LeftCollision/CollisionPolygon2D.disabled = false
	$Collisions/Loops/Loop9/LeftCollision/CollisionPolygon2D.disabled = false
	$Collisions/Loops/Loop10/LeftCollision/CollisionPolygon2D.disabled = false
	$"Collisions/Loops/Loop 12/LeftCollision/CollisionPolygon2D".disabled = false
	$Collisions/Loops/Loop11/LeftCollision/CollisionPolygon2D.disabled = false
	#------------------------------Tile Maps------------------------------#
	$"Egg Fleet/TileMapZ1(Left)".collision_enabled = true
func _disable_right_loop() -> void:
	$"Collisions/Loops/Loop 11/RightCollision/CollisionPolygon2D".disabled = true
	$Collisions/Loops/Loop1/RightCollision/CollisionPolygon2D.disabled = true
	$"Collisions/Start 1/Loop2/RightCollision/CollisionPolygon2D".disabled = true
	$Collisions/Loops/Loop3/RightCollision/CollisionPolygon2D.disabled = true
	$Collisions/Loops/Loop4/RightCollision/CollisionPolygon2D.disabled = true
	$Collisions/Loops/Loop5/RightCollision/CollisionPolygon2D.disabled = true
	$Collisions/Loops/Loop6/RightCollision/CollisionPolygon2D.disabled = true
	$Collisions/Loops/Loop7/RightCollision/CollisionPolygon2D.disabled = true
	$Collisions/Loops/Loop8/RightCollision/CollisionPolygon2D.disabled = true
	$Collisions/Loops/Loop9/RightCollision/CollisionPolygon2D.disabled = true
	$Collisions/Loops/Loop10/RightCollision/CollisionPolygon2D.disabled = true
	$"Collisions/Loops/Loop 12/RightCollision/CollisionPolygon2D2".disabled = true
	$Collisions/Loops/Loop11/RightCollision/CollisionPolygon2D.disabled = true
	#------------------------------Tile Maps------------------------------#
	$"Egg Fleet/TileMapZ0(Right)".collision_enabled = false
	
func _enable_right_loop() -> void:
	$"Collisions/Loops/Loop 11/RightCollision/CollisionPolygon2D".disabled = false
	$Collisions/Loops/Loop1/RightCollision/CollisionPolygon2D.disabled = false
	$"Collisions/Start 1/Loop2/RightCollision/CollisionPolygon2D".disabled = false
	$Collisions/Loops/Loop3/RightCollision/CollisionPolygon2D.disabled = false
	$Collisions/Loops/Loop4/RightCollision/CollisionPolygon2D.disabled = false
	$Collisions/Loops/Loop5/RightCollision/CollisionPolygon2D.disabled = false
	$Collisions/Loops/Loop6/RightCollision/CollisionPolygon2D.disabled = false
	$Collisions/Loops/Loop7/RightCollision/CollisionPolygon2D.disabled = false
	$Collisions/Loops/Loop8/RightCollision/CollisionPolygon2D.disabled = false
	$Collisions/Loops/Loop9/RightCollision/CollisionPolygon2D.disabled = false
	$Collisions/Loops/Loop10/RightCollision/CollisionPolygon2D.disabled = false
	$"Collisions/Loops/Loop 12/RightCollision/CollisionPolygon2D2".disabled = false
	$Collisions/Loops/Loop11/RightCollision/CollisionPolygon2D.disabled = false
	#------------------------------Tile Maps------------------------------#
	$"Egg Fleet/TileMapZ0(Right)".collision_enabled = true

func _disable_left_loop() -> void:
	$"Collisions/Loops/Loop 11/LeftCollision/CollisionPolygon2D".disabled = true
	$Collisions/Loops/Loop1/LeftCollision/CollisionPolygon2D.disabled = true
	$"Collisions/Start 1/Loop2/LeftCollision/CollisionPolygon2D".disabled = true
	$Collisions/Loops/Loop3/LeftCollision/CollisionPolygon2D.disabled = true
	$Collisions/Loops/Loop4/LeftCollision/CollisionPolygon2D.disabled = true
	$Collisions/Loops/Loop5/LeftCollision/CollisionPolygon2D.disabled = true
	$Collisions/Loops/Loop6/LeftCollision/CollisionPolygon2D.disabled = true
	$Collisions/Loops/Loop7/LeftCollision/CollisionPolygon2D.disabled = true
	$Collisions/Loops/Loop8/LeftCollision/CollisionPolygon2D.disabled = true
	$Collisions/Loops/Loop9/LeftCollision/CollisionPolygon2D.disabled = true
	$Collisions/Loops/Loop10/LeftCollision/CollisionPolygon2D.disabled = true
	$"Collisions/Loops/Loop 12/LeftCollision/CollisionPolygon2D".disabled = true
	$Collisions/Loops/Loop11/LeftCollision/CollisionPolygon2D.disabled = true
	#------------------------------Tile Maps------------------------------#
	$"Egg Fleet/TileMapZ1(Left)".collision_enabled = false
	

func _Enable_up_path() -> void:
	$Collisions/AlternateUP/StaticBody2D/CollisionPolygon2D.disabled = false
	$Collisions/AlternateUP/StaticBody2D/CollisionPolygon2D2.disabled = false
	$Collisions/AlternateUP/StaticBody2D/CollisionPolygon2D3.disabled = false
	$Collisions/AlternateUP/StaticBody1/CollisionPolygon2D2.disabled = false
	#----------------------------------------------------------------------#
	$Collisions/AlternateUP/StaticBody1/CollisionPolygon2D.disabled = false
	$Collisions/AlternateUP/StaticBody2D/CollisionPolygon2D.disabled = false
	$Collisions/AlternateUP/StaticBody2D/CollisionPolygon2D.disabled = false
	$Collisions/AlternateUP/StaticBody2D4/CollisionPolygon2D.disabled = false
	$Collisions/AlternateUP/StaticBody2D5/CollisionPolygon2D.disabled = false

func _Disable_up_path() -> void:
	$Collisions/AlternateUP/StaticBody2D/CollisionPolygon2D.disabled = true
	$Collisions/AlternateUP/StaticBody2D/CollisionPolygon2D2.disabled = true
	$Collisions/AlternateUP/StaticBody2D/CollisionPolygon2D3.disabled = true
	$Collisions/AlternateUP/StaticBody1/CollisionPolygon2D2.disabled = true
	#----------------------------------------------------------------------#
	$Collisions/AlternateUP/StaticBody1/CollisionPolygon2D.disabled = true
	$Collisions/AlternateUP/StaticBody2D/CollisionPolygon2D.disabled = true
	$Collisions/AlternateUP/StaticBody2D/CollisionPolygon2D.disabled = true
	$Collisions/AlternateUP/StaticBody2D4/CollisionPolygon2D.disabled = true
	$Collisions/AlternateUP/StaticBody2D5/CollisionPolygon2D.disabled = true

func _Enable_down_path() -> void:
	$Collisions/AlternateDOWN/StaticBody2/CollisionPolygon2D.disabled = false
	$Collisions/AlternateDOWN/StaticBody2/CollisionPolygon2D2.disabled = false
	#----------------------------------------------------------------------#
	$Collisions/AlternateDOWN/StaticBody1/CollisionPolygon2D.disabled = false
	$Collisions/AlternateDOWN/StaticBody2/CollisionPolygon2D.disabled = false
	$Collisions/AlternateDOWN/StaticBody2/CollisionPolygon2D.disabled = false
	#-----------------------------------------------------------------------#
	$Collisions/AlternateDOWN/Wall/CollisionPolygon2D.disabled = false
	

func _Disable_down_path() -> void:
	$Collisions/AlternateDOWN/StaticBody2/CollisionPolygon2D.disabled = true
	$Collisions/AlternateDOWN/StaticBody2/CollisionPolygon2D2.disabled = true
	#----------------------------------------------------------------------#
	$Collisions/AlternateDOWN/StaticBody1/CollisionPolygon2D.disabled = true
	$Collisions/AlternateDOWN/StaticBody2/CollisionPolygon2D.disabled = true
	#-----------------------------------------------------------------------#
	$Collisions/AlternateDOWN/Wall/CollisionPolygon2D.disabled = true
	
#-----------------------Area Signals-------------------------#
func _on_left_to_right_body_entered(body: Player) -> void:
	loop_middle_point = false
	loop_start_left = true
	loop_start_right = false

func _on_middle_point_body_entered(body: Player) -> void:
	loop_middle_point = true


func _on_right_to_left_body_entered(body: Player) -> void:
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
	Global.physics_state = Global.gameplay_state.wall_movement
	Global.GRAVITY = 0


func _on_wall_body_exited(body: Player) -> void:
	Global.physics_state = Global.gameplay_state.physics
	Global.GRAVITY = 0



func _on_combat_zone_body_entered(body: Player) -> void:
	pass
	#Global.exit_wall_state = false
	#Global.physics_state = Global.gameplay_state.wall_movement
	#Global.GRAVITY = 0


func _on_combat_zone_body_exited(body: Player) -> void:
	pass
	#Global.exit_wall_state = true
	#Global.GRAVITY = 0


func _null_head_stopper_entered(body: Player) -> void:
	Global.null_head_stopper = true


func _null_head_stopper_exited(body: Player) -> void:
	Global.null_head_stopper = false
