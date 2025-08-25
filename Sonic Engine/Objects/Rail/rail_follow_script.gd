extends PathFollow2D

@onready var remote_transform := $RailRemote
@onready var rail_aim_sprite := $AimSprite
@onready var rail_path := $".."
@onready var rail_path_follow := $"."
var player
@onready var activate_hitbox = $activate_rail/CollisionShape2D
@export var rail_speed := 5.0
func _ready() -> void:
	set_meta("aim", rail_aim_sprite)
	Global.EnemyPostitions.append(rail_aim_sprite)
	Global.rails_positions.append(self)
	rail_aim_sprite.hide()
	
func _process(delta: float) -> void:
	if	Global.ExitedRail == true:
			_exit_rail()

func _exit_rail() -> void:
	player = Global.player_node
	remove_child(remote_transform)
	Global.CanRail = false
	activate_hitbox.disabled = true
	player.control_lock = false
	player.jumping = true
	await get_tree().create_timer(0.20).timeout
	player.facing_direction_lock = false
	activate_hitbox.disabled = false
	player.rotation = 0
	
	
func _on_activate_rail_body_entered(body: Player) -> void:
	Global.CanRail = true
	Global.ExitedRail = false
	rail_aim_sprite.hide()
	# Assign RemoteTransform2D to the player
	remote_transform.remote_path = body.get_path()
	add_child(remote_transform)


func _on_homing_attck_body_entered(body: Player) -> void:
	Global.CanHomeAttack = true
	activate_hitbox = $activate_rail/CollisionShape2D
	if activate_hitbox.disabled == false:
		rail_aim_sprite.show()


func _on_homing_attck_body_exited(body: Player) -> void:
	Global.CanHomeAttack = false
	rail_aim_sprite.hide()
