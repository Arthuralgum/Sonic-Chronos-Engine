extends PathFollow2D
@onready var RemoteTransform = $RailRemoteTransform
@onready var player = $"../../../Player"
@onready var RailAimSprite = $RailAimSprite
@onready var RailPath = $".."
var is_railing: bool = false
var initial_offset
func _ready() -> void:
	Global.EnemyPostitions.append(RailAimSprite)


func _process(delta: float) -> void:
	print(RailPath.curve.get_closest_offset(player.position))
	if !Global.CanRail:
		initial_offset = RailPath.curve.get_closest_offset(player.position)
		progress = initial_offset
	if Global.CanRail:
		Global.GRAVITY = 0
		add_child(RemoteTransform)
		v_offset = 0
		var railSpeed : = 20.0
		if player.last_facing_direction == Vector2(1.0,0.0):
			progress += railSpeed
			Global.CanHomeAttack = false
			if progress_ratio == 1 or Input.is_action_just_pressed("jump"):
				Global.GRAVITY = 900
				remove_child(RemoteTransform)
				Global.CanRail = false
				Global.ExitedRail = true
				$ActivateRail/CollisionShape2D.disabled = true
				await get_tree().create_timer(0.5).timeout
				$ActivateRail/CollisionShape2D.disabled = false
				player.rotation = 0
				progress_ratio = 0
		elif player.last_facing_direction == Vector2(-1.0,0.0):
			progress -= railSpeed
			Global.CanHomeAttack = false
			if progress_ratio == 0 or Input.is_action_just_pressed("jump"):
				Global.GRAVITY = 900
				remove_child(RemoteTransform)
				Global.CanRail = false
				Global.ExitedRail = true
				$ActivateRail/CollisionShape2D.disabled = true
				await get_tree().create_timer(0.5).timeout
				$ActivateRail/CollisionShape2D.disabled = false
				player.rotation = 0
				progress_ratio = 0
		
func _on_can_homeattck_body_entered(body: Node2D) -> void:
	Global.CanHomeAttack = true
	RailAimSprite.show()
	
func _on_can_homeattck_body_exited(body: Node2D) -> void:
	Global.CanHomeAttack = false
	RailAimSprite.hide()
	
func _on_activate_rail_body_entered(body: Node2D) -> void:
	RailAimSprite.hide()
	Global.CanRail = true
	Global.ExitedRail = false
