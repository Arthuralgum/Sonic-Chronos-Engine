extends Node2D

@export var front_sprite: Sprite2D
@export var inside_sprite: Sprite2D
@export var tile_map: TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_inside_area_body_entered(body: Player) -> void:
	if front_sprite != null:
		front_sprite.hide()

func _on_inside_area_body_exited(body: Player) -> void:
	if front_sprite != null:
		front_sprite.show()
