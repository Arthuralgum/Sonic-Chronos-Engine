extends Node2D
@export var dash_panel_intensity: float = -1000
@onready var direction: RayCast2D = $Direction
@onready var Player: CharacterBody2D = get_node("/root/Node2D/Player")
var active: bool = false

func _process(delta: float) -> void:
	if active:
		Global.dash_panel_velocity.emit(get_global_transform().y.normalized() * dash_panel_intensity)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		active = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	active = false
