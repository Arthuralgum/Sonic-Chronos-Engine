extends Path2D
@onready var dash_aim_sprite := $DashFollow2D/AimSprite
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_meta("aim", dash_aim_sprite)
	$"..".register_light_dash(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
