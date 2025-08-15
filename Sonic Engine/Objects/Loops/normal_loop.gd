extends Node2D
@export var right_collision_Static_: StaticBody2D
@export var left_collision_Static_: StaticBody2D
@export var right_collision_TileMap_: TileMap
@export var left_collision_TileMap_: TileMap
var loop_middle_point: bool = false
var start_right: bool = false
var start_left: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_right_body_entered(body: Player) -> void:
	if right_collision_Static_ != null and left_collision_Static_ != null:
		right_collision_Static_.collision_layer = 0
		right_collision_Static_.collision_mask = 0
		left_collision_Static_.collision_layer = 1
		left_collision_Static_.collision_mask = 1
	if right_collision_TileMap_ != null and left_collision_TileMap_ != null:
		right_collision_TileMap_.collision_enabled = false
		left_collision_TileMap_.collision_enabled = true

func _on_start_left_body_entered(body: Player) -> void:
	if right_collision_Static_ != null and left_collision_Static_ != null:
		left_collision_Static_.collision_layer = 0
		left_collision_Static_.collision_mask = 0
		right_collision_Static_.collision_layer = 1
		right_collision_Static_.collision_mask = 1
	if right_collision_TileMap_ != null and left_collision_TileMap_ != null:
		left_collision_TileMap_.collision_enabled = false
		right_collision_TileMap_.collision_enabled = true


func _on_turning_point_body_entered(body: Player) -> void:
	pass
	
