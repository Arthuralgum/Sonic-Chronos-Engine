class_name PlayerHitBox
extends Area2D
var damage: int
var is_attacking: bool = false
var is_on_cooldown: bool = false
@onready var animation = $"../.."
@onready var light_duration_timer = $"../Light_Attack/Duration"
@onready var light_cooldown_timer = $"../Light_Attack/Cooldown"
@onready var light_combo_timer = $"../Light_Attack/ComboTimer"
@onready var light_startup_timer = $"../Light_Attack/StartupTimer"
var can_combo: bool = false
var combo_count: int = 0
#A contagem das collisions comeca do 0 (ou seja, a collision_layer = 2,
#siginifica que e a camada 3 nesse caso)
func _ready() -> void:
	collision_layer = 3
	collision_mask = 2
	$LightAttack1.disabled = true
	$LightAttack2.disabled = true
	$LightAttack3.disabled = true
func _process(delta: float) -> void:
	if Global.physics_state == Global.gameplay_state.combat_mode:
		if Input.is_action_just_pressed("action1") and !is_on_cooldown:
			light_startup_timer.start()
			if combo_count == 3:
				combo_count = 0
			is_on_cooldown = true
			is_attacking = true
			await light_startup_timer.timeout
			if combo_count == 0 or combo_count == 3:
				damage = 25
				$LightAttack1.disabled = false
			if combo_count == 1:
				damage = 30
				$LightAttack2.disabled = false
			if combo_count == 2:
				damage = 40
				$LightAttack3.disabled = false
			#Allow combo
			can_combo = true
			if combo_count < 3:
				combo_count += 1
			#Attack cooldown
			await light_duration_timer.timeout
			is_attacking = false
			is_on_cooldown = true
			light_cooldown_timer
			await light_cooldown_timer.timeout
			is_on_cooldown = false
		elif Input.is_action_pressed("action2") and !is_on_cooldown:
			damage = 50
			is_attacking = true
			await get_tree().create_timer(0.4).timeout
			is_attacking = false
			is_on_cooldown = true
			await get_tree().create_timer(0.23).timeout
			is_on_cooldown = false
		if light_combo_timer.time_left < 0.01:
			light_combo_timer.stop()
			combo_count = 0
		if !is_attacking:
			$LightAttack1.disabled = true
			$LightAttack2.disabled = true
			$LightAttack3.disabled = true
