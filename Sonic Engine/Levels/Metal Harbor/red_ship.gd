extends Node2D
@export var front_sprite1: Sprite2D
@export var front_sprite2: Sprite2D
@export var wing_sprite: Sprite2D
@export var inside_sprite: Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_inside_area_body_entered(body: Player) -> void:
	if front_sprite1 != null:
		front_sprite1.hide()
	if front_sprite2 != null:
		front_sprite2.hide()
	if wing_sprite != null:
		wing_sprite.hide()


func _on_inside_area_body_exited(body: Player) -> void:
	if front_sprite1 != null:
		front_sprite1.show()
	if front_sprite2 != null:
		front_sprite2.show()
	if wing_sprite != null:
		wing_sprite.show()
