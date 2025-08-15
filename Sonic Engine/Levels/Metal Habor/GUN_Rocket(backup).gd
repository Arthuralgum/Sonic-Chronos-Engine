extends CharacterBody2D


@onready var player = $"../../../Player"
@onready var camera = $"../../../Camera2D"

@onready var MH_Soundtrack = $"../../../MH_SoundTrack"
@onready var EGG_FLEET_Soundtrack = $"../../../EGG_FLEET_SoundTrack"

@export var random_strength: float = 15.0
@export var shake_fade: float = 7.0
var rng = RandomNumberGenerator.new()
var shake_strength: float = 0.0

var player_entered: bool = false
var end_cutscene: bool = false
var Rocket_Movement: bool = false

var Soundtrack_fade_speed: float = 5

@export var acc: float = 15.0
@export var max_speed: float = 1500.0
func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	if player_entered:
		Rocket_Movement = true
		player.position = position + Vector2(0.0,12)
		player.control_lock = true
		player.motion.y = 0
		player.jumping = false
		player.animation.play("Holding")
		apply_shake()
		
		if shake_strength > 0:
			shake_strength = lerp(shake_strength,0.0,shake_fade * delta)
			camera.offset = random_offset()
		change_soundtrack(delta)
	if end_cutscene:
		Rocket_Movement = true
		player_entered = false
		player.control_lock = false
		player.motion.x = 1000
		await get_tree().create_timer(1).timeout
		end_cutscene = false
		await get_tree().create_timer(1.5).timeout
		Rocket_Movement = false
	if Rocket_Movement:
		if velocity.y > -max_speed:
			velocity.y -= acc
		else:
			velocity.y = -max_speed
			
	move_and_slide()
func apply_shake():
	shake_strength = random_strength
func random_offset() -> Vector2:
	return Vector2(
		rng.randf_range(-shake_strength, shake_strength),
		rng.randf_range(-shake_strength, shake_strength)
	)
func change_soundtrack(delta: float):
	if player_entered:
		await get_tree().create_timer(4.5).timeout
		MH_Soundtrack.volume_db -= Soundtrack_fade_speed * delta
	if end_cutscene:
		await get_tree().create_timer(0.5).timeout
		EGG_FLEET_Soundtrack.play()
func _on_hit_box_body_entered(body: Node2D) -> void:
	Global.Cutscene = true
	player_entered = true


func _on_stopper_body_entered(body: Player) -> void:
	player.motion.x = lerp(player.motion.x,0.0,0.7)


func _on_end_cutscene_body_entered(body: Player) -> void:
	end_cutscene = true
	Global.Cutscene = false
