
extends Area2D
var damage = 25
#A contagem das collisions comeca do 0 (ou seja, a collision_layer = 2,
#siginifica que e a camada 3 nesse caso)
func _ready() -> void:
	collision_layer = 3
	collision_mask = 2
