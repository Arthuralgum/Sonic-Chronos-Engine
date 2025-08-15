class_name EnemyHurtBox
extends Area2D


# Called when the node enters the scene tree for the first time.
#A contagem das collisions comeca do 0 (ou seja, a collision_layer = 2,
#siginifica que e a camada 3 nesse caso)
func _init() -> void:
	collision_layer = 2
	collision_mask = 3
func _ready() -> void:
	connect("area_entered", _ready)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_entered(hitbox: PlayerHitBox) -> void:
	if hitbox == null:
		return
	if owner.has_method("_take_damage"):
		owner._take_damage(hitbox.damage)
