extends Camera2D
@export var zoom_physics = Vector2(1.0,1.0)
@export var zoom_combat = Vector2(2.0,2.0)
@export var zoom_speed = Vector2(0.2, 0.2)
@export var zoom_system = Vector2(1.0,1.0)
@export var camera_speed_min: float = 7.0
@export var camera_speed_max: float = 8.0
var player

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	player = Global.player_node
	if player.motion.x <= 750:
		position = lerp(position,player.position, camera_speed_min * delta)
	else:
		position = lerp(position,player.position, camera_speed_max * delta)
	if Global.physics_state == Global.gameplay_state.combat_mode:
			zoom = lerp(zoom, zoom_combat, 0.2)
	elif Global.physics_state == Global.gameplay_state.physics:
			zoom = lerp(zoom, zoom_physics, 0.2)
