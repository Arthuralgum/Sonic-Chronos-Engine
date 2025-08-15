extends Node2D
@onready var ItemAimSprite = $Aim
@onready var ItemSprite = $ItemSprite
@onready var hit_box_area: CollisionShape2D = $"CollisionArea/HitBox Area"
@onready var homing_attack_area: CollisionShape2D = $"CanHomingAttackArea/Homing Attack Area"
@export var ammount: int = 30

@onready var sound_effect: AudioStreamPlayer2D = $"Sound Effect"

var entered: bool = false
var EnemyHP: int = 100
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.EnemyPostitions.append(ItemAimSprite)
	ItemAimSprite.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_can_homing_attack_area_body_entered(body: Player) -> void:
	if !entered:
		Global.CanHomeAttack = true
		ItemAimSprite.show()

func _on_can_homing_attack_area_body_exited(body: Player) -> void:
		Global.CanHomeAttack = false
		ItemAimSprite.hide()


func _on_collision_area_body_entered(body: Player) -> void:
	if !entered:
		entered = true
		Global.Rings += ammount
		Global.Score += ammount * 100
		Global.Energy += ammount
		sound_effect.play()
		ItemAimSprite.hide()
		ItemSprite.hide()
		hit_box_area.disabled = true
		homing_attack_area.disabled = true
		Global.EnemyPostitions.erase(ItemAimSprite)
		Global.CanHomeAttack = false
		await get_tree().create_timer(1.0).timeout
		queue_free()
