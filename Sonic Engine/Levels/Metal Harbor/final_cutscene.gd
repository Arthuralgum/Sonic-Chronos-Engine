extends Node2D

var follow_path := false
@export var random_strength: float = 7.0
@export var shake_fade: float = 7.0
var rng = RandomNumberGenerator.new()
var shake_strength: float = 0.0
var can_apply_shake: bool = true
var explosion_valide: bool = true

func _ready() -> void:
	$Animation.play("Cutscene")
	$Path2D/PathFollow2D/Sonic.hide()
	await get_tree().create_timer(4.08).timeout
	start_cutscene()
	await get_tree().create_timer(4.92).timeout
	System.ExitStageTo("res://System/UI/Level Selection Screen/Level selection screen.tscn")
func _process(delta: float) -> void:
	if explosion_valide == true:
		explosions()
	if can_apply_shake == true:
		apply_shake()
		if shake_strength > 0:
			shake_strength = lerp(shake_strength,0.0,shake_fade * delta)
			$Camera2D.offset = random_offset()
	if not follow_path or $Path2D/PathFollow2D.progress_ratio >= 1.0:
		# Follow normal Sonic
		$Path2D/PathFollow2D/Sonic.hide()
		$Sonic.show()
		$Camera2D.global_position = $Sonic.global_position
	else:
		# Follow Sonic on PathFollow2D
		$Path2D/PathFollow2D.progress_ratio += 1.1 * delta
		$Camera2D.global_position = $Path2D/PathFollow2D.global_position
		

func start_cutscene() -> void:
	# Call this when starting the cutscene
	$Sonic.hide()
	$Path2D/PathFollow2D/Sonic.show()
	follow_path = true
func explosions():
	var explosion_nodes = [
		$"Explosions/Explosion 1",
		$"Explosions/Explosion 2",
		$"Explosions/Explosion 3",
		$"Explosions/Explosion 4",
		$"Explosions/Explosion 5",
		$"Explosions/Explosion 6",
		$"Explosions/Explosion 7", 
		$"Explosions/Explosion 8", 
		$"Explosions/Explosion 9", 
		$"Explosions/Explosion 10", 
		$"Explosions/Explosion 11", 
		$"Explosions/Explosion 12", 
		$"Explosions/Explosion 13", 
		$"Explosions/Explosion 14", 
		$"Explosions/Explosion 15", 
		$"Explosions/Explosion 16", 
		$"Explosions/Explosion 17", 
		$"Explosions/Explosion 18", 
		$"Explosions/Explosion 19", 
		$"Explosions/Explosion 20", 
		$"Explosions/Explosion 21", 
		$"Explosions/Explosion 22", 
		$"Explosions/Explosion 23", 
		$"Explosions/Explosion 24", 
		$"Explosions/Explosion 25", 
		$"Explosions/Explosion 26", 
		$"Explosions/Explosion 27"
	]
	
	var delays = [0.2116, 0.3069, 0.4185, 0.6407, 0.7100, 0.800, 1.1351, 1.3352, 1.3402, 1.3452, 1.7796, 2.1044, 2.2988, 2.496, 2.4825, 2.6653, 2.8067, 2.8167, 3.0472, 3.3252, 3.5541, 3.7157, 3.7197, 3.7237, 3.7307, 3.9283, 4.0358]  # match timing for each
	
	var last_time = 0.0
	
	for i in range(explosion_nodes.size()):
		var wait_time = delays[i] - last_time
		if wait_time > 0:
			await get_tree().create_timer(wait_time).timeout
		
		var e = explosion_nodes[i]
		e.show()
		e.play("default")
		
		last_time = delays[i]
	explosion_valide = false
func apply_shake():
	
	shake_strength = random_strength
func random_offset() -> Vector2:
	return Vector2(
		rng.randf_range(-shake_strength, shake_strength),
		rng.randf_range(-shake_strength, shake_strength)
	)


func _on_shake_timer_timeout() -> void:
	can_apply_shake = false
