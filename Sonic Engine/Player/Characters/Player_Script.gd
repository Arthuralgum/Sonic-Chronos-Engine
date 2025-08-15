extends CharacterBody2D

class_name Player
@export var character_select = Character.Sonic
enum Character {Sonic, Shadow,Shadow_motorcicle, Super_Shadow, Metal_Sonic, Neo_Metal, Super_Neo_Metal}
@onready var SonicNode := $"."
@onready var collision := $Collision
@onready var animation := $Animations
@onready var sprite := $Sprite
@onready var slopecast := $SlopeCast

var facing_direction_lock: bool = false
var is_transforming: bool = false

var motion := Vector2(0, 0)

var rot := 0.0

var grounded := false
var got_down: bool = false
var got_up: bool = false

var facing_direction: Vector2 = Vector2.RIGHT
var last_facing_direction: Vector2

var slopeangle := 0.0

var slopefactor := 0.0

var wall_fall_timer = false
var falloffwall: bool = false
var exited_wall: bool = true
var wall_state_jump: bool = false
var wall_state_spindash_charge: bool = false
var wall_state_spindash_released: bool = false

var control_lock: bool = false

var stuck: bool = false

var air_boost: bool = false
var jumping: bool = false
var jumpcount: int = 0
var canjump: bool = false
var jumpbuffered: bool = false
var spring_jump: bool = false
var jump_velocity = 400.0

var jumpAnimStart: bool = false
var stoppingAnimStart: bool = false
var fallingAnimStart: bool = false
var fall_loopAnimStart: bool = false

var is_guarding: bool = false
var combo_count: int = 0
var can_combo: bool = false
var is_light_attack: bool = false
var is_heavy_attack: bool = false
var is_cooldown:bool = false
var can_attack: bool = false
@onready var dash_timer = $Sprite/Combat/DashTimer
@onready var dash_recharge_timer = $Sprite/Combat/DashRecharge
var recharging_dash: bool = false
@onready var HB_LA_1 = $Sprite/Combat/AttackHitBox/LightAttack1
@onready var HB_LA_2 = $Sprite/Combat/AttackHitBox/LightAttack2
@onready var HB_LA_3 = $Sprite/Combat/AttackHitBox/LightAttack3
var has_changed_direction = false

var is_dodging: bool = false
var can_dodge: bool = true
var anim_dodging: bool = false

@onready var duration_timer = $Sprite/Combat/Light_Attack/Duration
@onready var cooldown_timer = $Sprite/Combat/Light_Attack/Cooldown
@onready var combo_timer = $Sprite/Combat/Light_Attack/ComboTimer

var is_dropdash_charging: bool = false
var dropdash_released: bool = true
var is_spindashing_charging: bool = false
var is_peel_out_charging: bool = false
var spindash_released: bool = false
var peel_out_released: bool = false
var is_slope_dash: bool = false
var speed_charge: float = 0
var speed_charge_started: bool = false
@export var spin_dash_min: float = 300
@export var spin_dash_max: float = 1600
@export var spin_dash_acc: float = 100
@export var peel_out_min: float = 400
@export var peel_out_max: float = 2000
@export var peel_out_acc: float = 250
var peel_out_anim_acc: float

var bounce_anim_finished: bool = false
var bouncing_state: bool = false
var bounced: bool = false
var bounce_fall_velocity: float = 1500
var bounce_velocity: float = 500

var acc := 2
# Acceleration. Default: 2
# This is what moves you forward.

const dec := 30.0
# Deccelleration. Default: 30.0

var topspeed := 1200.0

var life = 100


var jumpsoundcount: int = 0

var boost_cooldown: float = 0.2

var damage_immunity := false

var immunity_time := 4

#Preset Stuff:

var spindash_lock: bool
var peelout_lock: bool
var dropdash_lock: bool
var bounce_lock: bool
var homing_attack_lock: bool
var boost_lock: bool

var preset_path := "user://preset_data"

func load_all_presets():
	if FileAccess.file_exists(preset_path):
		var file = FileAccess.open(preset_path, FileAccess.READ)
		presets = file.get_var()

var presets := {
	"preset1": {},
	"preset2": {},
	"preset3": {}
}

func apply_preset_settings(preset_name: String):
	if not presets.has(preset_name):
		return
	var data = presets[preset_name]
	spindash_lock = data.get("spindash", false)
	peelout_lock = data.get("peelout", false)
	dropdash_lock = data.get("dropdash", false)
	bounce_lock = data.get("bounce", false)
	homing_attack_lock = data.get("homing_attack", false)
	boost_lock = data.get("boost", false)
	topspeed = data.get("topspeed", 1200)
	acc = data.get("acceleration", 2)
	jump_velocity = data.get("jump_velocity", 400)

func apply_motion(direction, delta):
	if is_on_floor():# If touching the floor...
		if sign(direction) == sign(motion.x): # If you're holding in the direction you're moving...
			if abs(motion.x) <= topspeed: # If you're not over your Top Speed...
				motion.x += (acc*2) * direction * delta * 120
				# Accelerate in the direction you're holding.
			else:
				motion.x = clamp(motion.x, -topspeed, topspeed)
				
		else: # If you're trying to turn around... 
			if abs(motion.x) <= topspeed:
				if abs(slopefactor) < 0.2: # If you're standing on flat or slightly slanted ground...
					motion.x += (dec*0.5) * direction * delta * 120
					# Very quickly Deccelerate to a stop.
				else: # If you're standing on a far too steep slope...
					if motion.x >= 0:
						motion.x -= (acc*2) * delta * 120
					elif motion.x < 0:
						motion.x += (acc*2) * delta * 120
					# Turn at normal speed.
					## Logically, it would be pretty hard to slow down when running down a hill.
			else:
				motion.x = clamp(motion.x, -topspeed, topspeed)
			#else:
				#motion.x = move_toward(motion.x, topspeed * direction, acc * delta * 120)
			
	else: # If mid-air...
		if sign(direction) == sign(motion.x): # If you're holding in the direction you're moving...
			if abs(motion.x) <= topspeed: # If you're not over your Top Speed...
				motion.x += (acc * 2) * direction * delta * 120
				# Accelerate (a bit faster) in the direction you're holding.
		else:  # If you're trying to turn around...
			if abs(motion.x) <= topspeed:
				motion.x += (acc * 2) * direction * delta * 120
				# Deccellerate at the same speed.
			else:
				motion.x = move_toward(motion.x, topspeed * direction,acc)

func apply_player_rotation(delta):
	#Player rotation
	if is_on_floor():
		if !bounced:
			jumpcount = 0
		slopeangle = get_floor_normal().angle() + (PI/2)
		slopefactor = get_floor_normal().x
	else:
		slopefactor = 0
		
	$Collision.rotation = rot
	sprite.rotation = lerp_angle(sprite.rotation, rot, 0.25)
	
	if is_on_floor():
		if not grounded:
			if abs(slopeangle) >= 0.25 and abs(motion.y) > abs(motion.x):
				motion.x += motion.y * slopefactor * delta * 100
			grounded = true
		
		up_direction = get_floor_normal()
		rot = slopeangle
	else:
		if not $Collision/Raycast.is_colliding() and grounded:
			grounded = false
			
			motion = get_real_velocity()
			rot = 0
			up_direction = Vector2(0, -1)

func apply_gravity(delta):
	# Gravity
	if air_boost:
		boost_cooldown -= delta
		if boost_cooldown <= 0:
			air_boost = false
	elif !Global.ExitedRail:
		if not is_on_floor() and rot == 0 and !Global.CanRail and !Global.CanLightDash:
			motion.y += Global.GRAVITY * delta * 1.4
		else:
			if !Global.IsSpringJumping:
				if abs(slopefactor) == 1:
					motion.y = 0
				else:
					motion.y = 50

func momentum(direction):
# Slopes
	if is_on_floor() and not stuck and not $Collision/WallCast.is_colliding():
		motion.x += (acc * 2) * slopefactor
		# When you're moving down a slope, add more acceleration.
		# When you're moving up a slope, slow the player down.
		## This is what gives Momentum.
		## Without this, running up walls would be too unnaturally easy.
	if grounded and abs(slopeangle) > 1.15 and abs(slopeangle) <= 1.7: # If you're on a wall...
		if abs(motion.x) < 200:
			if !wall_fall_timer:
				wall_fall_timer = true
				$WallFallTimer.start()
		else:
			# Reset if player speeds up again before timer ends
			wall_fall_timer = false
			$WallFallTimer.stop()
	if grounded and abs(slopeangle) > 1.7 and abs(motion.x) < 100:
		velocity += Vector2(0, -300).rotated(rot) # This pushes the character down from the ceiling
		control_lock = true
	if grounded and abs(slopeangle) < 0.7:
		control_lock = false
	else:
		falloffwall = false
# Stoppers
	if $Collision/RoofCast.is_colliding() and not grounded and Global.null_head_stopper == false: # If you bonk your head on the ceiling...
		if motion.y < 0: # If you're moving up...
				motion.y = 100
			# Get sent right back down.
			
#Beta
	#if is_on_floor() and not slopecast.is_colliding() and abs(slopefactor) > 0.2 and !bouncing_state and !bounced:
		#facing_direction_lock = true
		#if facing_direction == Vector2.RIGHT:
			#motion.x += 0.75 * (acc) * (1 + abs(slopefactor)*1.25)
		#elif facing_direction == Vector2.LEFT:
			#motion.x -= 0.75 * (acc) * (1 + abs(slopefactor)*1.25)
	#if is_on_floor() and !direction and slopecast.is_colliding() and abs(slopefactor) > 0.2 and !bouncing_state and !bounced:
		#facing_direction_lock = true
		#if facing_direction == Vector2.RIGHT:
			#motion.x -= 0.75 * (acc) * (1 + abs(slopefactor)*1.25)
		#elif facing_direction == Vector2.LEFT:
			#motion.x += 0.75 * (acc) * (1 + abs(slopefactor)*1.25)
	#if abs(slopefactor) <= 0.2 and !Global.CanRail:
		#facing_direction_lock = false

func select_dash_charge():
	if !is_on_floor():
		motion.x = motion.x
		is_dropdash_charging = true
	else:
		motion.x = lerp(motion.x, 0.0, 0.2)
		if got_down:
			is_spindashing_charging = true
		elif got_up:
			is_peel_out_charging = true

func release_dash():
	if is_spindashing_charging or is_dropdash_charging or is_peel_out_charging:
		motion.x = speed_charge * sign(facing_direction.x)
	elif !is_spindashing_charging and !is_dropdash_charging and !is_peel_out_charging:
		motion.x = motion.x
	if !is_peel_out_charging:
		spindash_released = true
	else:
		peel_out_released = true
	is_peel_out_charging = false
	is_spindashing_charging = false
	is_dropdash_charging = false

func damage_animation():
	var fade_time := 0.2
	for i in range(5):
		# Fade out
		for t in range(10):
			modulate.a = lerp(1.0, 0.0, t / 10.0)
			await get_tree().process_frame
		# Fade in
		for t in range(10):
			modulate.a = lerp(0.0, 1.0, t / 10.0)
			await get_tree().process_frame
	print("finished")

func check_can_take_damage():
	if damage_immunity or jumping or bouncing_state or bounced or spindash_released:
		Global.player_can_take_damage = false
	else:
		Global.player_can_take_damage = true

func take_damage():
	if damage_immunity:
		return  # Ignore if currently immune
	if Global.Rings > 0:
		Global.Rings = int(Global.Rings * 0.3)  # Keep it an integer
		#start_damage_immunity()
		damage_animation()
	else:
		System.ExitStageTo("res://System/UI/Level Selection Screen/Level selection screen.tscn")
		#"die"
func start_damage_immunity():
	damage_immunity = true
	await get_tree().create_timer(immunity_time).timeout
	damage_immunity = false

func _ready() -> void:
	load_all_presets()
	if System.selected_preset == System.presets.Preset1:
		apply_preset_settings("preset1")
	if System.selected_preset == System.presets.Preset2:
		apply_preset_settings("preset2")
	if System.selected_preset == System.presets.Preset3:
		apply_preset_settings("preset3")
	Global.dash_panel_velocity.connect(_has_entered_dash_panel)
	Global.boost_ring_motion.connect(_has_entered_boost_ring)
	Global.dash_pad_velocity.connect(_has_entered_dash_pad)
	Global.spring_jump_motion.connect(_has_entered_spring_jump)
	
	Global.ExitedRail = false
	Global.ExitedLightDash = false
func _process(delta):
	if Global.physics_state == Global.gameplay_state.wall_movement and !Global.CanRail:
		exited_wall = false
		$Collision.rotation = 0
		sprite.rotation = 0
		_wall_movment(delta)
	if Global.physics_state == Global.gameplay_state.physics:
		exited_wall = true
		Global.GRAVITY = 900
		#Reset rotation from wall movement
		rotation = 0
		#--------------------------------#
		_physics(delta)
		#animate()
		test_animate()
	if Global.physics_state == Global.gameplay_state.combat_mode:
		_combat_mode(delta)
		
func _physics(delta):
	var direction = Input.get_axis("left", "right") # Emits "-1" if holding left, and "1" if holding right.
	apply_gravity(delta)
	apply_player_rotation(delta)
	if is_on_floor():
		jumping = false
		Global.ExitedLightDash = false
		Global.ExitedRail = false
		Global.CanHomeAttack = false
	if Global.ExitedRail or Global.ExitedLightDash:
		jumpcount = 1
		if Input.is_action_just_pressed("jump"):
			Global.ExitedRail = false
			Global.ExitedLightDash = false
	if !is_on_floor() and Global.CouldHomeattack:
		Global.CanHomeAttack = true
#Homing Attack
	if Input.is_action_just_pressed("jump") and !is_on_floor() and Global.EnemyPostitions != [] and Global.closestEnemy != null and Global.CanHomeAttack == true:
		global_position = Global.get_closest_enemy(global_position).global_position
		motion.y = -jump_velocity * delta * 100
		if jumpcount >= 1:
			jumpcount = 1
# Jump
	if Input.is_action_just_pressed("jump") and !bouncing_state and !is_spindashing_charging:
		jumpbuffered = true
		$JumpBufferTimer.start()
	if not grounded and canjump and !bouncing_state:
		if $CoyoteTimer.is_stopped():
			$CoyoteTimer.start()
	else:
		$CoyoteTimer.stop()
	if jumpbuffered and canjump and !bouncing_state:
		motion.y = -jump_velocity * delta * 100
		jumpAnimStart = true
		jumping = true
		canjump = false
		jumpcount += 1
		$JumpBufferTimer.stop()
	jumpbuffered = false
	if not grounded and Input.is_action_just_pressed("jump") and jumpcount < 2 and !bouncing_state and !is_dropdash_charging and !Global.CanHomeAttack and !Global.IsSpringJumping and !air_boost:
		motion.y = -jump_velocity * delta * 100
		jumpcount += 1
#Bounce
	if !is_on_floor() and (jumping or jumpcount >= 1) and Input.is_action_just_pressed("exit") and !Global.CanRail:
		bounced = false
		bouncing_state = true
		if bouncing_state:
			motion = Vector2(motion.x, bounce_fall_velocity * 1.2) * delta * 60
	if is_on_floor() and bouncing_state:
		sprite.rotation = rot
		jumpcount += 1
		motion.y = 0
		motion = Vector2(motion.x * 0.4, -bounce_velocity * 1.8) * delta * 60
	if motion.y < -300 and bouncing_state:
		bounced = true
		bouncing_state = false
	if motion.y >= 0 and grounded:
		bounced = false
		canjump = true
	if jumping and !bouncing_state and !bounced and !air_boost and !Global.IsSpringJumping and !Global.ExitedRail and motion.y < -jump_velocity / 1.625:
		if not Input.is_action_pressed("jump"):
			motion.y = -jump_velocity / 1.625
# SpinDash
	if Input.is_action_just_pressed("action1") and !spindash_released and !peel_out_released:
		select_dash_charge()
	if (Input.is_action_just_released("action1") and (is_spindashing_charging or is_peel_out_charging)) or ((is_dropdash_charging and is_on_floor()) and !spindash_released) or (((get_floor_normal().x > 0.3 and sign(facing_direction.x) > 0) or (get_floor_normal().x < -0.3 and sign(facing_direction.x) < 0)) and got_down):
		release_dash()
	if is_dropdash_charging or is_spindashing_charging:
		_spindash_charge()
		control_lock = true
	elif is_peel_out_charging:
		_peel_out_charge()
		control_lock = true
	if spindash_released:
		control_lock = true
		if (Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("action1") or Input.is_action_just_pressed("exit")) or ((abs(motion.x) < 500)):
			speed_charge = 0
			speed_charge_started = false
			control_lock = false
			spindash_released = false
	if peel_out_released:
		control_lock = true
		if (Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("action1") or Input.is_action_just_pressed("exit")) or ((abs(motion.x) < 500)):
			speed_charge = 0
			speed_charge_started = false
			control_lock = false
			peel_out_released = false
# Movement
	#Direction
	if !Global.CanRail:
		if direction > 0:
			facing_direction = Vector2.RIGHT
			last_facing_direction = Vector2.RIGHT
		if direction == 0:
			facing_direction = last_facing_direction
		if direction < 0:
			facing_direction = Vector2.LEFT
			last_facing_direction = Vector2.LEFT
	if direction and not control_lock: # If holding left or right, and not slipping down a slope...
		apply_motion(direction, delta)
	else: # If not pressing anything...
		if is_on_floor() and abs(slopefactor) < 0.25 and !spindash_released: # If you're on flat, or near-flat ground...
			motion.x = move_toward(motion.x, 0.0, acc*5)
		elif is_on_floor() and (spindash_released or peel_out_released) and ((slopefactor >= 0.25 and motion.x <= 0) or (slopefactor <= 0.25 and motion.x >= 0)):
			motion.x = move_toward(motion.x, 0.0, acc*5)
		else:
			motion.x = clamp(motion.x, -topspeed * 1.25, topspeed * 1.25)

# Set Velocity to the Motion variable, but rotated.
	velocity = Vector2(motion.x, motion.y).rotated(rot)
	# Right here's where the magic happens.
	# Since Velocity is a Vector2, we've cleverly created a separate Vector2 called "Motion" to-
	# -take all the commands that Velocity would normally take, to then give it right back to-
	# -Velocity with an added ".rotated()" function, which effortlessly rotates Motion based on
	# -your actual rotation, therefore letting you run up walls and stuff.
	if !Global.is_cutscene:
		test_animate()
	check_can_take_damage()
	momentum(direction)
	move_and_slide()
	_sfx()
var idle := true
var idleset := false
func test_animate():
	var started_jump_anim: bool = false
	var directionX = Input.get_axis("left", "right") # Emits "-1" if holding left, and "1" if holding right.
	var directionY = Input.get_axis("down", "up")
	var turning: bool = false
	if !facing_direction_lock:
		if directionX < -0.1:
			facing_direction = Vector2.LEFT
			last_facing_direction = Vector2.LEFT
		elif directionX > 0.1:
			facing_direction = Vector2.RIGHT
			last_facing_direction = Vector2.RIGHT
		elif directionX >= -0.1 and directionX <= 0.1:
			facing_direction = last_facing_direction
		if sign(directionX) == sign(motion.x):
			if facing_direction == Vector2.RIGHT and !turning:
				sprite.flip_h = false
			elif facing_direction == Vector2.LEFT and !turning:
				sprite.flip_h = true
	elif (sign(directionX) != sign(motion.x) or directionX == 0.0) or facing_direction_lock:
		if motion.x > 0:
			sprite.flip_h = false
			facing_direction = Vector2.RIGHT
			last_facing_direction = Vector2.RIGHT
		elif motion.x < 0:
			sprite.flip_h = true
			facing_direction = Vector2.LEFT
			last_facing_direction = Vector2.LEFT
		else:
			facing_direction = last_facing_direction
	if !is_on_floor() and !jumping and !bounced and !bouncing_state and !Global.CanRail and !Global.boost_ring and !Global.IsSpringJumping and !spindash_released and !peel_out_released and !is_dropdash_charging:
		animation.play("Falling")
		animation.speed_scale = 1 + (abs(motion.x) / 1000)
	if jumping and jumpAnimStart and !started_jump_anim and !is_dropdash_charging and !is_spindashing_charging and !spindash_released and !Global.CanRail and !bouncing_state:
		animation.play("Jump")
		animation.speed_scale = 1 + (abs(motion.x) / 350)
		await animation.animation_finished
		jumpAnimStart = false
	if jumping and !jumpAnimStart and !is_dropdash_charging and !Global.CanRail and !bouncing_state:
		animation.play("Jump_Loop")
		animation.speed_scale = 1 + (abs(motion.x) / 350)
	if exited_wall and animation.name == "Wall_Run":
			animation.play("Jump_Loop")
	if bouncing_state:
		if is_on_floor():
			animation.play("Bounce_Up")
			await animation.animation_finished
			animation.play("Spindash_Released")
		elif !is_on_floor() and !bounced:
			animation.play("Spindash_Released")
	elif Global.CanRail:
		animation.play("Rail")
	if Global.boost_ring and !is_on_floor():
		jumping = false
		bouncing_state = false
		animation.play("Air_Boost")
		await get_tree().create_timer(2.0).timeout
		jumping = true
#-------------------------------------------SPINDASH ANIM-----------------------------------------
	if is_dropdash_charging or is_spindashing_charging:
		jumping = false
		animation.speed_scale = 1
		animation.play("Spindash_Charge")
		sprite.offset.y = 7.5
	elif is_peel_out_charging:
		jumping = false
		animation.speed_scale += peel_out_anim_acc
		animation.play("Peel_Out_Charge")
		sprite.offset.y = 2.0
	elif spindash_released:
		animation.speed_scale = 1
		animation.play("Spindash_Released")
		sprite.offset.y = 7.5
	elif peel_out_released:
		animation.speed_scale = 1
		animation.play("Peel_Out_Release")
		sprite.offset.y = 0.4
	else:
		if animation.name != "Spindash_Released":
			sprite.offset.y = 0
#-------------------------------------WALKING, RUNNING, IDLE ANIMS--------------------------------
	if (is_on_floor() or $Collision/Raycast.is_colliding()) and !bouncing_state and !bounced and !spindash_released and !is_peel_out_charging and !peel_out_released and !is_spindashing_charging:
		if abs(motion.x) <= 50 and abs(slopeangle) < 0.21 and !turning:
			animation.speed_scale = 1
			if Input.get_axis("down", "up") < -0.7 and abs(motion.x) < 0.5:
				if !got_down:
					animation.play("Get_Down")
					got_down = true
			elif Input.get_axis("down", "up") > 0.7 and abs(motion.x) < 0.5:
					if !got_up:
						animation.play("Get_Up")
						got_up = true
			else:
				animation.play("Idle")
				got_down = false
				got_up = false
		if ((directionX >= 0 and motion.x >= 50) or (directionX <= 0 and motion.x <= -50)):
				if abs(motion.x) > 50 and abs(motion.x) < 250 and !got_down:
					animation.play("Walk")
					animation.speed_scale = 1 + (abs(motion.x) / 350)
				elif abs(motion.x) >= 250:
					animation.play("Run")
					animation.speed_scale = 1 + (abs(motion.x) / 350)
		#elif ((directionX < 0 and motion.x >= 0) or (directionX > 0 and motion.x <= 0) or (abs(motion.x) > 5.0 and directionX == 0)) and slope_factor > 0.92:
			#if abs(motion.x) <= 2.0:
				#turning = true
				#animation.play("RunTurn")
				#await animation.animation_finished
				#turning = false
		elif sign(directionX) != sign(motion.x):
			if abs(motion.x) > 100.0:
				animation.play("Stopping")
		if Input.get_axis("down", "up") < -0.7:
			got_down = true
		elif Input.get_axis("down", "up") >= -0.7:
			got_down = false
		if Input.get_axis("down", "up") > 0.7:
			got_up = true
		elif Input.get_axis("down", "up") <= 0.7:
			got_up = false
func _sfx():
	if Input.is_action_just_pressed("action1") and (is_dropdash_charging or is_spindashing_charging):
		$Sfx/SpinDashCharge.play()
		$Sfx/SpinDashRelease.stop()
	if Input.is_action_just_pressed("action1") and is_peel_out_charging:
		$Sfx/PeelOutCharge.play()
		$Sfx/PeelOutRelease.stop()
	if Input.is_action_just_released("action1") and spindash_released:
		$Sfx/SpinDashCharge.stop()
		$Sfx/SpinDashRelease.play()
	if Input.is_action_just_released("action1") and peel_out_released:
		$Sfx/PeelOutCharge.stop()
		$Sfx/PeelOutRelease.play()
	if Input.is_action_just_pressed("jump") and jumpsoundcount < 2 and !(is_dropdash_charging or is_spindashing_charging):
		jumpsoundcount += 1
		$Sfx/Jump.play()
		$Sfx/SpinDashCharge.stop()
	if is_on_floor():
		jumpsoundcount = 0
func _wall_animate():
	rotation = velocity.angle() - 3*PI/2
	if velocity.x >= velocity.y:
		animation.speed_scale = 1.0 + (abs(velocity.x) / 2)
	else:
		animation.speed_scale = 1.0 + (abs(velocity.y) / 2)
	if Global.physics_state == Global.gameplay_state.wall_movement:
		if wall_state_jump:
			animation.play("Spindash_Charge_Wall")
		else:
			animation.play("Wall_Run")
func _combat_animate():
	$Sprite.speed_scale = 1
	$Sprite/Combat/AttackHitBox.scale.x = -1 * sign(velocity.x)
	var direction = Input.get_vector("left", "right", "up", "down")
	var combat_idle: bool = false
	if character_select == Character.Neo_Metal:
		if direction == Vector2(0,0):
			$Sprite.play("idle(neo_metal)")
		elif velocity.x >= 0:
			$Sprite.flip_h = true
			$Sprite.play("walk(neo_metal)")
		elif velocity.x < 0:
			$Sprite.flip_h = false
			$Sprite.play("walk(neo_metal)")
	elif character_select == Character.Shadow:
			if !is_heavy_attack and !is_light_attack:
				if anim_dodging:
					$Sprite.play_backwards("Dodge(shadow)")
					await $Sprite.animation_finished
					anim_dodging = false
				elif !is_dodging and !is_guarding and direction:
					if velocity.x > 10:
						$Sprite.flip_h = true
						$Sprite.play("walk_(shadow)")
					elif velocity.x < -10:
						$Sprite.flip_h = false
						$Sprite.play("walk_(shadow)")
				elif is_guarding:
					$Sprite.play("guard(shadow)")
				elif !is_guarding and !is_dodging:
					$Sprite.play("idle(shadow)")
			elif is_light_attack:
				if combo_count == 0 or combo_count == 3:
					$Sprite.play("light_attack_1(shadow)")
				elif combo_count == 1:
					$Sprite.play("light_attack_2(shadow)")
				elif combo_count == 2:
					$Sprite.play("light_attack_3(shadow)")
			elif is_heavy_attack:
				$Sprite/Effects.show()
				$Sprite.play("Heavy_Final")
				$Sprite/Effects.play("default")
				await $Sprite.animation_finished
				is_heavy_attack = false
			else:
				$Sprite.play("idle(shadow)")
			
# Timer signals
func _on_control_lock_timer_timeout():
	control_lock = false
	# After a brief moment, your ability to move left and right is restored.

func _on_jump_buffer_timer_timeout():
	jumpbuffered = false
	# If you pressed jump but aren't close enough to the ground, it stops buffering your jump.

func _on_coyote_timer_timeout():
	canjump = false
	# If you've been in the air for too long, your ability to jump is revoked.

#On walls movment
func _wall_movment(delta):
	#Resetting config:
	is_dropdash_charging = false
	is_spindashing_charging = false
	spindash_released= false
	jumping = false
	bouncing_state = false
	bounced = false
	var side_dash: bool = false
	var previous_velocity
	#------------------------------------#
	var direction = Input.get_vector("left", "right", "up", "down")
	Global.GRAVITY = 0
	bouncing_state = false
	var speed = 100
	velocity += direction * speed * acc * delta
	motion = velocity
	move_and_slide()
	_wall_animate()
	if Input.is_action_just_pressed("jump"):
		wall_state_jump = true
		await get_tree().create_timer(0.6).timeout
		wall_state_jump = false
	#if Input.is_action_just_released("jump"):
		#wall_state_jump = false
	if Input.is_action_just_pressed("action1"):
		pass
	elif Input.is_action_just_pressed("secondary1"):
		side_dash = true
		previous_velocity = velocity
		var perpendicular_velocity = Vector2.RIGHT.rotated(rotation) * speed * 23
		if rotation_degrees < -135 and rotation_degrees > -225:
			velocity = -perpendicular_velocity
		else:
			velocity = perpendicular_velocity
		await get_tree().create_timer(0.05).timeout
		velocity = previous_velocity
		await get_tree().create_timer(0.1).timeout
	elif Input.is_action_just_pressed("secondary2"):
		side_dash = true
		previous_velocity = velocity
		var perpendicular_velocity = Vector2.RIGHT.rotated(rotation) * speed * 23
		if rotation_degrees < -135 and rotation_degrees > -225:
			velocity = perpendicular_velocity
		else:
			velocity = -perpendicular_velocity
		await get_tree().create_timer(0.05).timeout
		velocity = previous_velocity
		await get_tree().create_timer(0.1).timeout
	if Input.is_action_just_pressed("exit") or (abs(velocity.x) < 130 and abs(velocity.y) < 150 and not side_dash) or Global.physics_state != Global.gameplay_state.wall_movement or (!wall_state_jump and Global.exit_wall_state):
		Global.GRAVITY = 900
		Global.physics_state = Global.gameplay_state.physics
		exited_wall = true
		#animate()
		test_animate()
			
			
func _combat_mode(delta):
	motion = velocity
	var direction = Input.get_vector("left", "right", "up", "down")
	var dodge_direction
	Global.GRAVITY = 0
	var speed = 25000
	var top_velocityX = 300.0
	var top_velocityY = 300.0
	var top_velocity = Vector2(300.0,300.0)
	if direction != Vector2(0.0, 0.0) and !control_lock:
		velocity = lerp(velocity, direction * speed * delta, 0.05 )
		if direction.x > 0:
			facing_direction = Vector2.RIGHT
			last_facing_direction = Vector2.RIGHT
			has_changed_direction = false
		elif direction.x < 0:
			facing_direction = Vector2.LEFT
			last_facing_direction = Vector2.LEFT 
			has_changed_direction = false
	elif !is_dodging:
		has_changed_direction = false
		facing_direction = last_facing_direction
		velocity = lerp(velocity, Vector2(0.0,0.0) , 0.4)
	
	if Input.is_action_just_pressed("exit"):
		if is_cooldown:
			await get_tree().create_timer(0.4).timeout
		is_guarding = true
		control_lock = true
	if (Input.is_action_just_released("exit") or is_light_attack) and is_guarding:
		is_guarding = false
		control_lock = false
	if Input.is_action_just_pressed("jump") and !anim_dodging and !is_dodging:
		anim_dodging = true
		control_lock = true
		is_dodging = true
		velocity = sign(direction) * speed * delta * 1.5
		dash_timer.start()
	if is_dodging:
		can_dodge = false
		if dash_timer.time_left < 0.01:
			dash_recharge_timer.start()
			recharging_dash = true
			velocity = (direction) * speed * delta
			is_dodging = false
			can_dodge = true
			if !is_guarding:
				control_lock = false
	if dash_recharge_timer.time_left < 0.01:
		recharging_dash = false
		dash_recharge_timer.stop()
		
	if Input.is_action_just_pressed("action1") and !is_cooldown:
		# combo_timer must be combo_timer > duration_timer + cooldown_timer
		combo_timer.start()
		if combo_count == 3:
			combo_count = 0
		if combo_count == 0:
			can_combo = true
		#Attack setup
		is_cooldown = true
		control_lock = true
		is_light_attack = true
		#Attack Duration
		duration_timer.start()
		await duration_timer.timeout
		control_lock = false
		is_light_attack = false
		#Allow combo
		can_combo = true
		if combo_count < 3:
			combo_count += 1
		#Attack cooldown
		cooldown_timer.start()
		await cooldown_timer.timeout
		is_cooldown = false
	if combo_timer.time_left < 0.01:
		combo_timer.stop()
		combo_count = 0
	if Input.is_action_just_pressed("action2"):
		is_heavy_attack = true
	move_and_slide()
	_combat_animate()
	
func _has_entered_dash_panel(dash_force: Vector2) -> void:
	velocity = dash_force
func _has_entered_boost_ring(dash_force: Vector2) -> void:
	motion = dash_force
	air_boost = true
	boost_cooldown = 0.2
func _has_entered_dash_pad(dash_force: Vector2) -> void:
	control_lock = true
	motion = dash_force
	await get_tree().create_timer(0.3).timeout
	control_lock = false
func _has_entered_spring_jump(dash_force: Vector2) -> void:
	motion.y = dash_force.y
	motion.x = 0.0
	spring_jump = true
	boost_cooldown = 0.2
	
func _spindash_charge():
	print(speed_charge)
	if !speed_charge_started:
		speed_charge = spin_dash_min
		speed_charge_started = true
	speed_charge = move_toward(speed_charge, spin_dash_max, spin_dash_acc)
func _peel_out_charge():
	print(speed_charge)
	if !speed_charge_started:
		speed_charge = peel_out_min
		speed_charge_started = true
	speed_charge = move_toward(speed_charge, peel_out_max, peel_out_acc)


func _on_wall_fall_timer_timeout() -> void:
	if grounded and abs(slopeangle) > 1.15 and abs(motion.x) < 200:
		falloffwall = true
		position += Vector2(0, -14).rotated(rot)
		control_lock = true
		$ControlLockTimer.start()
	wall_fall_timer = false


func _on_player_hit_box_body_entered(body: Node2D) -> void:
	pass
