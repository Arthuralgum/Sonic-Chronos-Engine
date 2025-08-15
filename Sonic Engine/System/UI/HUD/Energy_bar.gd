extends TextureProgressBar
@onready var energy_bar_full_: AnimatedSprite2D = $"../../MarginContainer/Energy_Bar(Full)"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	value = Global.Energy
	if value >= max_value:
		energy_bar_full_.play("Full")
	else:
		energy_bar_full_.play("Default")
