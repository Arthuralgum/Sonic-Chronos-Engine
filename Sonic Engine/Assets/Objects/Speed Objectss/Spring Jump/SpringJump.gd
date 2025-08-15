extends Node2D
@onready var SpringNode = $"."
@onready var AimSprite = $Aim
@onready var SpringSprite = $AnimatedSprite2D
@export var SpringJumpForce:float = 1000
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.CanSpringJump = false
	AimSprite.hide()
	Global.EnemyPostitions.append(SpringNode)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.IsSpringJumping:
		var player = Global.player_node
func _on_detection_area_body_entered(body: Player) -> void:
	Global.EnemyPostitions.append(SpringNode)
	AimSprite.hide()
	Global.IsSpringJumping = true
	Global.CanHomeAttack = false
	Global.CanSpringJump = false
	var player = Global.player_node
	player.position += Vector2(0.0,-50).rotated(rotation)
	player.motion = Vector2(0.0,-SpringJumpForce).rotated(rotation)
	SpringSprite.play("Spring")
	$AudioStreamPlayer2D.play()


func _on_detection_area_body_exited(body: Player) -> void:
	Global.CanHomeAttack = true
	Global.CanSpringJump = true
	await get_tree().create_timer(0.1).timeout
	Global.IsSpringJumping = false

func _on_can_homing_attack_area_body_entered(body: Player) -> void:
	AimSprite.show()
	Global.CanHomeAttack = true
	Global.CouldHomeattack = true
	Global.CanSpringJump = true

func _on_can_homing_attack_area_body_exited(body: Player) -> void:
	AimSprite.hide()
	Global.CanHomeAttack = false
	Global.CouldHomeattack = false
	Global.CanSpringJump = false
