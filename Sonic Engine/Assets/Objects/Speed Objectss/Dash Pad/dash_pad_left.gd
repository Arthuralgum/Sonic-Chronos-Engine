extends Node2D
@export var dash_pad_intensity: float = 2000
var active: bool = false

func _process(delta: float) -> void:
	pass
func _on_area_2d_body_entered(body: Node2D) -> void:
	var player = Global.player_node
	if body is Player:
		if abs(sin(rotation)) <= 0.95:
			if abs(rotation) <= PI/2:
				player.motion = Vector2(-dash_pad_intensity,0.0).rotated(abs(rotation))
			else:
				player.motion = Vector2(dash_pad_intensity,0.0).rotated(abs(rotation))
		else:
			if abs(rotation) <= PI:
				player.motion = Vector2(0.0,dash_pad_intensity).rotated(abs(rotation))
			else:
				player.motion = Vector2(0.0,-dash_pad_intensity).rotated(abs(rotation))
func _on_area_2d_body_exited(body: Node2D) -> void:
	active = false
