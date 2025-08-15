extends PathFollow2D

@onready var remote_transform := $RailRemote
@onready var dash_aim_sprite := $AimSprite
@onready var dash_path := $".."
var player
var can_dash: bool = false
@onready var activate_hitbox = $activate_rail/CollisionShape2D
@export var rail_speed := 5.0
func _ready() -> void:
	set_meta("aim", dash_aim_sprite)
	$"../..".register_light_dash_follow(self)
	
func _process(delta: float) -> void:
	player = Global.player_node
	if Global.ExitedLightDash == true:
			_exit_rail()
	if can_dash:
		if Input.is_action_just_pressed("exit") or Input.is_action_just_pressed("action2"):
			Global.CanLightDash = true
			Global.ExitedLightDash = false
			# Assign RemoteTransform2D to the player
			remote_transform.remote_path = player.get_path()
			add_child(remote_transform)
func _exit_rail() -> void:
	player = Global.player_node
	Global.GRAVITY = 900
	remove_child(remote_transform)
	Global.CanLightDash = false
	player.control_lock = false
	player.jumping = true
	player.facing_direction_lock = false
	await get_tree().create_timer(0.3).timeout
	player.rotation = 0
	
	
func _on_activate_dash_body_entered(body: Player) -> void:
	can_dash = true


func _on_activate_dash_body_exited(body: Player) -> void:
	can_dash = false
