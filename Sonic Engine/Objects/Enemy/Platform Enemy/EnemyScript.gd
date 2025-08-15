extends CharacterBody2D
@export var EnemyHP: int = 100
@export var Score: int = 100
@export var AnimatedSprite: AnimatedSprite2D
func _ready() -> void:
	$Aim.hide()
	var EnemyAim = $Aim
	Global.EnemyPostitions.append(EnemyAim)
func _on_hitbox_body_shape_entered(body_rid: RID, body: Player, body_shape_index: int, local_shape_index: int) -> void:
	var player = Global.player_node
	if body.damage_immunity:
		return
	if Global.player_can_take_damage == false :
		var EnemyAim = $Aim
		AnimatedSprite.hide()
		$Aim.hide()
		Global.Score += Score
		Global.EnemyPostitions.erase(EnemyAim)
		Global.CanHomeAttack = false
		Global.CouldHomeattack = false
		queue_free()
		EnemyHP = 0
	else:
		body.take_damage()
func _on_area_2d_body_shape_entered(body_rid: RID, body: Player, body_shape_index: int, local_shape_index: int) -> void:
	$Aim.show()
	Global.CanHomeAttack = true
	Global.CouldHomeattack = true
func _on_area_2d_body_shape_exited(body_rid: RID, body: Player, body_shape_index: int, local_shape_index: int) -> void:
	if EnemyHP > 0:
		$Aim.hide()
		Global.CanHomeAttack = false
		Global.CouldHomeattack = false
	


func _on_idle_timer_timeout() -> void:
	if AnimatedSprite.animation == "TurnRight":
		AnimatedSprite.play("TurnLeft")
	elif AnimatedSprite.animation == "TurnLeft":
		AnimatedSprite.play("TurnRight")
