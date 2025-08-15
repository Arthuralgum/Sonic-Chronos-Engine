extends Node2D
@export var boost_intensity: float = 875
var boost_vector
@onready var direction: RayCast2D = $Direction
func _process(delta: float) -> void:
	pass
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		Global.boost_ring = true
		Global.boost_ring_motion.emit(get_global_transform().x * boost_intensity)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		await get_tree().create_timer(2.0).timeout
		Global.boost_ring = false
