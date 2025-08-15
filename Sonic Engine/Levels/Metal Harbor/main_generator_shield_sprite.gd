extends TextureRect
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if $"..".generators_destroyed < 3:
		animation_player.play("Pulse")
	else:
		animation_player.play("Destroyed")
