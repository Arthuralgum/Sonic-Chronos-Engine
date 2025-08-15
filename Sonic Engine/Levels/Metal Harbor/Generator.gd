extends Node2D
@export var animation: AnimatedSprite2D
@export var aimsprite: Sprite2D
var Destroyed: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	aimsprite.hide()
	animation.play("Default")
	Global.EnemyPostitions.append(aimsprite)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_homing_attack_body_entered(body: Player) -> void:
	if !Destroyed:
		aimsprite.show()
		Global.CanHomeAttack = true

func _on_hit_box_body_entered(body: Player) -> void:
	Destroyed = true
	$"../Main".generators_destroyed += 1
	aimsprite.hide()
	animation.play("Destroyed")
	Global.CanHomeAttack = false
	

func _on_homing_attack_body_exited(body: Player) -> void:
	aimsprite.hide()
	Global.CanHomeAttack = false
