extends Sprite2D
var follow_path := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(4.08).timeout
	follow_path = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not follow_path or $"../Path2D/PathFollow2D".progress_ratio >= 0.8:
		global_position = lerp(global_position, $"../Sonic".position, 0.25)
	else:
		global_position = lerp(global_position, $"../Path2D/PathFollow2D".position, 0.25)
	
