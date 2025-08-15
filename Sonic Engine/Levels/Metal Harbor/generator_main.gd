extends Node2D
var generators_destroyed: int = 0
@onready var EnemyAim: Sprite2D = $Aim

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EnemyAim.hide()
	Global.EnemyPostitions.append(EnemyAim)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$ProgressNumber.text = str(generators_destroyed) + " / 3"
	

func _on_collision_body_entered(body: Node2D) -> void:
	if generators_destroyed >= 3:
		EnemyAim.hide()
		Global.Score += 5000
		Global.EnemyPostitions.erase(EnemyAim)
		Global.CanHomeAttack = false
		Global.CouldHomeattack = false
		$Fade.show()
		await get_tree().create_timer(1.0).timeout
		Global.Cutscene_ring = Global.Rings
		Global.Cutscene_score = Global.Score
		System.ExitStageTo("res://Levels/Metal Harbor/final_cutscene.tscn")
		

func _on_homing_attack_area_body_exited(body: Player) -> void:
	if generators_destroyed >= 3:
		EnemyAim.hide()
		Global.CanHomeAttack = false
		Global.CouldHomeattack = false

func _on_homing_attack_area_body_entered(body: Player) -> void:
	if generators_destroyed >= 3:
		EnemyAim.show()
		Global.CanHomeAttack = true
		Global.CouldHomeattack = true
