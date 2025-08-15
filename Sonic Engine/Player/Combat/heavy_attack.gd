extends Node2D
@onready var duration_timer = $Duration
@onready var cooldown_timer = $Cooldown
@export var attack_duration: float = 0.1
@export var attack_cooldown: float = 0.1
@export var damage: float = 50

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
