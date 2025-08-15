extends Area2D
@onready var sound_effect: AudioStreamPlayer2D = $"Sound Effect"
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var collision_area: CollisionShape2D = $CollisionArea


var entered: bool = false
func _ready() -> void:
	sprite.play("Default")
func _process(delta: float) -> void:
	pass
func _on_body_entered(body: Player) -> void:
	if !entered:
		entered = true
		Global.Rings += 1
		Global.Score += 100
		Global.Energy += 1
		sound_effect.play()
		collision_area.disabled = true
		sprite.hide()
		await get_tree().create_timer(1.0).timeout
		queue_free()
