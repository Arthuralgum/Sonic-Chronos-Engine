extends Node2D
@export var dash_pad_intensity: float = 2000
@onready var Player: CharacterBody2D = get_node("/root/Node2D/Player")
var active: bool = false

func _process(delta: float) -> void:
	pass
func _on_area_2d_body_entered(body: Node2D) -> void:
	var player = Global.player_node
	if body is Player:
		var angle = rad_to_deg(rotation / TAU)
		if sin(angle) <= 0.95 and sin(angle) >= 0.0:
			if rotation <= PI/2 and rotation >= 0.0:
				player.motion = Vector2(-dash_pad_intensity,0.0).rotated(rotation)
				print("AAAAAAAAAAAAAAAAAAAAAA")
			else:
				player.motion = Vector2(dash_pad_intensity,0.0).rotated(rotation)
				print("BBBBBBBBBBBBBBBBBBBBBBBBBBB")
		elif sin(angle) < 0.0:
			player.motion = Vector2(-dash_pad_intensity,0.0).rotated(rotation)
			print("CCCCCCCCCCCCCCCCCCCCCCCCCCCC")
		else:
			print("DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD")
			player.motion = Vector2(0.0,-dash_pad_intensity).rotated(rotation)
func _on_area_2d_body_exited(body: Node2D) -> void:
	active = false
