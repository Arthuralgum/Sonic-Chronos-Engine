extends CharacterBody2D
## First of all, lest declare the variables we will be using...
@export var character_select = Character.Sonic
enum Character {Sonic, Shadow,Shadow_motorcicle, Super_Shadow, Metal_Sonic, Neo_Metal, Super_Neo_Metal}
##These variables are just to declare the nodes we will be interacting with
##(Think of it as a fancier way to call the node than just using: $"NODE_NAME")
@onready var SonicNode := $"."
@onready var Animations := $Sprite
@onready var collision := $Collision
@onready var animation := $Animation
@onready var slopecast := $SlopeCast

##The following variables are for physics related stuff: Running, jumping, Spindashing and etc...
var facing_direction_lock: bool = false

var motion := Vector2(0, 0)
# Motion, consider it a Semi-Velocity.
##Think of is as a more "flexible" Velocity
##Which will be suited better for this Engine

var rot := 0.0
# Rotation.
## This helps your Sprite and Collision rotate.

var grounded := false

var got_down: bool = false
#This will be used to detect if the player got down (To use a spindash for example)
## It will be used mainly in the animation and spindash part

var facing_direction: Vector2 = Vector2.RIGHT
var last_facing_direction: Vector2


var slopeangle := 0.0
var slopefactor := 0.0
#The slopes variables, these will be used to calculate
##The Change in Velocity when Going up, or down a hill

var falloffwall: bool = false
var exited_wall: bool = true

var control_lock: bool = false

var stuck: bool = false

var boost_ring: bool = false
var jumping: bool = false
var jumpcount: int = 0
var canjump: bool = false
var jumpbuffered: bool = false
var JUMP_VELOCITY = 400.0

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
var spindash_released: bool = false
var is_slope_dash: bool = false
var speed_charge: float = 0
var speed_charge_started: bool = false
@export var speed_charge_min: float = 300
@export var speed_charge_max: float = 1600
@export var speed_charge_acc: float = 100

var bouncing_state: bool = false
var bounced: bool = false
var bounce_fall_velocity: float = 1500
var bounce_velocity: float = 500

const acc := 2
# Acceleration. Default: 2
# This is what moves you forward.

const dec := 30.0
# Deccelleration. Default: 30.0

const topspeed := 1200.0

var life = 100


var jumpsoundcount: int = 0

var boost_ring_cooldown: float = 0.2


func _ready() -> void:
	Global.dash_panel_velocity.connect(_has_entered_dash_panel)
	Global.boost_ring_motion.connect(_has_entered_boost_ring)
	Global.dash_pad_velocity.connect(_has_entered_dash_pad)
	
	Global.ExitedRail = false
	Global.ExitedLightDash = false
func _process(delta):
	if Global.physics_state == Global.gameplay_state.wall_movement and !Global.CanRail:
		exited_wall = false
		collision.rotation = 0
		animation.rotation = 0
		_wall_movment(delta)
	if Global.physics_state == Global.gameplay_state.physics:
		exited_wall = true
		Global.GRAVITY = 900
		#Reset rotation from wall movement
		rotation = 0
		#--------------------------------#
		_physics(delta)
		test_animate()
	if Global.physics_state == Global.gameplay_state.combat_mode:
		_combat_mode(delta)
func _physics(delta):
#Homing Attack
	if is_on_floor():
		jumping = false
		Global.HasSpringJump = false
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
	if Input.is_action_just_pressed("jump") and !is_on_floor() and Global.EnemyPostitions != [] and Global.closestEnemy != null and Global.CanHomeAttack == true:
			global_position = Global.get_closest_enemy(global_position).global_position
			if !Global.IsSpringJumping and !Global.CanSpringJump:
				motion.y = -JUMP_VELOCITY * delta * 100
			if jumpcount >= 1:
				jumpcount = 1
#Player rotation
	if is_on_floor():
		jumpcount = 0
		slopeangle = get_floor_normal().angle() + (PI/2)

		slopefactor = get_floor_normal().x
	else:
		slopefactor = 0
		
	$Collision.rotation = rot
	$Sprite.rotation = lerp_angle($Sprite.rotation, rot, 0.25)
	$Animation.rotation = lerp_angle($Animation.rotation, rot, 0.25)
	
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
# Gravity
	if boost_ring:
		boost_ring_cooldown -= delta
		if boost_ring_cooldown <= 0:
			boost_ring = false
	elif !boost_ring:
		if not is_on_floor() and rot == 0 and !Global.CanRail and !Global.CanLightDash and !boost_ring:
			motion.y += Global.GRAVITY * delta * 1.4
		else:
			if abs(slopefactor) == 1:
				motion.y = 0
			else:
				motion.y = 50
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
		motion.y = -JUMP_VELOCITY * delta * 100
		jumpAnimStart = true
		jumping = true
		canjump = false
		jumpcount += 1
		if abs(rot) > 1:
			position += Vector2(0, -(14)).rotated(rot)
		$JumpBufferTimer.stop()
	jumpbuffered = false
	if not grounded and Input.is_action_just_pressed("jump") and jumpcount < 2 and !bouncing_state and !is_dropdash_charging and !Global.CanHomeAttack and !Global.IsSpringJumping and !Global.CanSpringJump and !boost_ring:
		motion.y = -JUMP_VELOCITY * delta * 100
		jumpcount += 1
#Bounce
	if !is_on_floor() and (jumping or jumpcount >= 1) and Input.is_action_just_pressed("exit") and !Global.CanRail:
		bounced = false
		bouncing_state = true
		if bouncing_state:
			motion = Vector2(motion.x, bounce_fall_velocity * 1.2) * delta * 60
			move_and_collide(motion * delta)
	if is_on_floor() and bouncing_state:
		jumpcount += 1
		motion.y = 0
		motion = Vector2(motion.x * 0.4, -bounce_velocity * 1.2) * delta * 60
		position += Vector2(0, -(14)).rotated(rot)
		move_and_collide(motion * delta)
	if motion.y < -300 and bouncing_state:
		bounced = true
		bouncing_state = false
	if motion.y >= 0 and grounded:
		bounced = false
		canjump = true
	if jumping and !bouncing_state and !bounced and !boost_ring and !Global.IsSpringJumping and !Global.HasSpringJump and motion.y < -JUMP_VELOCITY / 1.625:
		if not Input.is_action_pressed("jump"):
			motion.y = -JUMP_VELOCITY / 1.625
#Spring Jump
	if Global.IsSpringJumping:
		jumping = true
		Global.GRAVITY = 0
		motion.y = -Global.SpringJumpForce
# SpinDash
	if Input.is_action_just_pressed("action1") and !spindash_released:
		if is_on_floor() and got_down:
			is_spindashing_charging = true
		elif !is_on_floor():
			is_dropdash_charging = true
	if (Input.is_action_just_released("action1") and is_spindashing_charging) or ((is_dropdash_charging and is_on_floor()) and !spindash_released) or (((get_floor_normal().x > 0.3 and sign(facing_direction.x) > 0) or (get_floor_normal().x < -0.3 and sign(facing_direction.x) < 0)) and got_down):
		if is_spindashing_charging or is_dropdash_charging:
			motion.x = speed_charge * sign(facing_direction.x)
		elif !is_spindashing_charging and !is_dropdash_charging:
			motion.x = motion.x
		is_spindashing_charging = false
		is_dropdash_charging = false
		spindash_released = true
	if is_spindashing_charging:
		_spindash_charge()
		motion.x = lerp(motion.x, 0.0, 0.3)
		control_lock = true
	if is_dropdash_charging:
		_spindash_charge()
		motion.x = motion.x
		control_lock = true
	if spindash_released:
		control_lock = true
		if (Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("action1") or Input.is_action_just_pressed("exit")) or ((abs(motion.x) < 500)):
			speed_charge = 0
			speed_charge_started = false
			control_lock = false
			spindash_released = false
# Movement
	var direction = Input.get_axis("left", "right") # Emits "-1" if holding left, and "1" if holding right.
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
		if is_on_floor(): # If touching the floor...
			print(facing_direction)
			if sign(direction) == sign(motion.x): # If you're holding in the direction you're moving...
				if abs(motion.x) <= topspeed: # If you're not over your Top Speed...
					motion.x += (acc*2) * direction * delta * 120
					# Accelerate in the direction you're holding.
				else:
					motion.x = move_toward(motion.x, topspeed * direction,acc)
					
			else: # If you're trying to turn around...
				if abs(slopefactor) < 0.2: # If you're standing on flat or slightly slanted ground...
					motion.x += (dec*0.5) * direction * delta * 120
					# Very quickly Deccelerate to a stop.
				else: # If you're standing on a far too steep slope...
					if motion.x >= 0:
						motion.x -= (acc*2) * delta * 120
					elif motion.x < 0:
						motion.x += (acc*2) * delta * 120
						motion.y += 1
					# Turn at normal speed.
					## Logically, it would be pretty hard to slow down when running down a hill.
				
				
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
					motion.x = motion.x
			
			# Note: Due to logic, you can't quickly turn around mid-air.
			
	else: # If not pressing anything...
		if is_on_floor() and abs(slopefactor) < 0.25 and !spindash_released: # If you're on flat, or near-flat ground...
			motion.x = move_toward(motion.x, 0.0, acc*5)
		elif is_on_floor() and spindash_released and ((slopefactor >= 0.25 and motion.x <= 0) or (slopefactor <= 0.25 and motion.x >= 0)):
			motion.x = move_toward(motion.x, 0.0, acc*5)
	print(motion)
	if is_on_floor() and not slopecast.is_colliding() and abs(slopefactor) > 0.2 and !bouncing_state and !bounced:
		facing_direction_lock = true
		if facing_direction == Vector2.RIGHT:
			motion.x += 0.75 * (acc) * (1 + abs(slopefactor)*1.25)
		elif facing_direction == Vector2.LEFT:
			motion.x -= 0.75 * (acc) * (1 + abs(slopefactor)*1.25)
	if is_on_floor() and !direction and slopecast.is_colliding() and abs(slopefactor) > 0.2 and !bouncing_state and !bounced:
		facing_direction_lock = true
		if facing_direction == Vector2.RIGHT:
			motion.x -= 0.75 * (acc) * (1 + abs(slopefactor)*1.25)
		elif facing_direction == Vector2.LEFT:
			motion.x += 0.75 * (acc) * (1 + abs(slopefactor)*1.25)
	if slopefactor <= 0.2:
		facing_direction_lock = false
# Set Velocity to the Motion variable, but rotated.
	velocity = Vector2(motion.x, motion.y).rotated(rot)
	
	# Right here's where the magic happens.
	# Since Velocity is a Vector2, we've cleverly created a separate Vector2 called "Motion" to-
	# -take all the commands that Velocity would normally take, to then give it right back to-
	# -Velocity with an added ".rotated()" function, which effortlessly rotates Motion based on
	# -your actual rotation, therefore letting you run up walls and stuff.
	


# Slopes
	if is_on_floor() and not stuck and not $Collision/WallCast.is_colliding():
		motion.x += (acc * 2) * slopefactor
		# When you're moving down a slope, add more acceleration.
		# When you're moving up a slope, slow the player down.
		## This is what gives Momentum.
		## Without this, running up walls would be too unnaturally easy.
	
	if grounded and abs(slopeangle) > 1.65: # If you're on a wall...
		if abs(motion.x) < 80: # ...and you're moving too slow...
			falloffwall = true
			position += Vector2(0, -(14)).rotated(rot)
			canjump = false
			# Detatch from the wall.
			
			control_lock = true
			$ControlLockTimer.start()
			# Briefly lock the player's controls.
			## We wouldn't want them to awkwardly re-attatch to the wall over and over again.
	if abs(slopeangle) > 2.6:
		if motion.x < 50 and is_on_floor():
			position += Vector2(0, -(14)).rotated(rot)
	if grounded and abs(slopeangle) < 0.7:
		control_lock = false
	else:
		falloffwall = false
	


# Stoppers
	if is_on_ceiling() and not grounded: # If you bonk your head on the ceiling...
		if motion.y < 0: # If you're moving up...
			motion.y = 100
			# Get sent right back down.

	if is_on_wall() and $Collision/WallCast.is_colliding(): # If you bump into a wall...
		motion.x = 0
		# Stop moving.
	test_animate()
	move_and_slide()
	_sfx()
var idle := true
var idleset := false
func test_animate():
	var started_jump_anim: bool = false
	var directionX = Input.get_axis("left", "right") # Emits "-1" if holding left, and "1" if holding right.
	var directionY = Input.get_axis("down", "up")
	print(animation.animation)
	var turning: bool = false
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
			slopecast.rotation = 0
			$Animation.flip_h = false
		elif facing_direction == Vector2.LEFT and !turning:
			slopecast.rotation = PI
			$Animation.flip_h = true
	elif sign(directionX) != sign(motion.x) or facing_direction_lock:
		if motion.x >= 0:
			$Animation.flip_h = false
		elif motion.x <= 0:
			$Animation.flip_h = true
	if Global.CanRail:
		animation.play("run")
	if jumping and jumpAnimStart and !started_jump_anim and !is_dropdash_charging and !is_spindashing_charging and !spindash_released and !Global.CanRail:
		animation.play("jump")
		animation.speed_scale = 1 + (abs(motion.x) / 350)
		await animation.animation_finished
		jumpAnimStart = false
	if jumping and !jumpAnimStart or bounced and !is_dropdash_charging and !is_spindashing_charging and !spindash_released and !Global.CanRail:
		if is_on_floor() and slopeangle < 0.92 or Global.CanRail:
			animation.play("run")
		else:
			animation.play("jump_loop")
		animation.speed_scale = 1 + (abs(motion.x) / 350)
	if exited_wall and $Animation.animation == "wall_run":
			$Animation.play("jump_loop")
#-------------------------------------------SPINDASH ANIM-----------------------------------------
	if is_dropdash_charging or is_spindashing_charging:
		jumping = false
		animation.speed_scale = 1
		animation.play("spindash_charge")
		$Animation.offset.y = 7.5
	elif spindash_released:
		animation.speed_scale = 1
		animation.play("spindash_released")
		$Animation.offset.y = 7.5
	else:
		if animation.animation != "spindash_released":
			$Animation.offset.y = 0
#-------------------------------------WALKING, RUNNING, IDLE ANIMS--------------------------------
	if (is_on_floor() or $Collision/Raycast.is_colliding()) and !bouncing_state and !bounced and !spindash_released and !is_spindashing_charging:
		if abs(motion.x) <= 50 and abs(slopeangle) < 0.1 and !turning:
			animation.speed_scale = 1
			if Input.get_axis("down", "up") < -0.7 and abs(motion.x) < 0.5:
				if !got_down:
					animation.play("get_down")
					got_down = true
			else:
				animation.play("idle")
				got_down = false
		if ((directionX >= 0 and motion.x >= 50) or (directionX <= 0 and motion.x <= -50)):
				if abs(motion.x) > 50 and abs(motion.x) < 250 and !got_down:
					animation.play("walk")
					animation.speed_scale = 1 + (abs(motion.x) / 350)
				elif abs(motion.x) >= 250:
					animation.play("run")
					animation.speed_scale = 1 + (abs(motion.x) / 350)
		#elif ((directionX < 0 and motion.x >= 0) or (directionX > 0 and motion.x <= 0) or (abs(motion.x) > 5.0 and directionX == 0)) and slope_factor > 0.92:
			#if abs(motion.x) <= 2.0:
				#turning = true
				#animation.play("RunTurn")
				#await animation.animation_finished
				#print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
				#turning = false
		elif sign(directionX) != sign(motion.x):
			if abs(motion.x) > 100.0:
				animation.play("stopping")
		if Input.get_axis("down", "up") < -0.7:
			got_down = true
		elif Input.get_axis("down", "up") >= -0.7:
			got_down = false

func _sfx():
	if Input.is_action_just_pressed("action1") and (is_dropdash_charging or is_spindashing_charging):
		$Sprite/Sfx/SpinDashCharge.play()
		$Sprite/Sfx/SpinDashRelease.stop()
	if Input.is_action_just_released("action1") and spindash_released:
		$Sprite/Sfx/SpinDashCharge.stop()
		$Sprite/Sfx/SpinDashRelease.play()
	if Input.is_action_just_pressed("jump") and jumpsoundcount < 2 and !(is_dropdash_charging or is_spindashing_charging):
		jumpsoundcount += 1
		$Sprite/Sfx/Jump.play()
		$Sprite/Sfx/SpinDashCharge.stop()
	if is_on_floor():
		jumpsoundcount = 0
func _wall_animate():
	rotation = velocity.angle() - 3*PI/2
	if velocity.x >= velocity.y:
		$Animation.speed_scale = 1.0 + (abs(velocity.x) / 2)
	else:
		$Animation.speed_scale = 1.0 + (abs(velocity.y) / 2)
	if Global.physics_state == Global.gameplay_state.wall_movement:
		if character_select == Character.Sonic:
			$Sprite.play("running_wall(sonic)")
		elif character_select == Character.Shadow:
			$Animation.play("wall_run")
		elif character_select == Character.Super_Shadow:
			$Sprite.play("running_wall(super_shadow)")
func _combat_animate():
	$Sprite.speed_scale = 1
	$Sprite/Combat/AttackHitBox.scale.x = -1 * sign(velocity.x)
	var direction = Input.get_vector("left", "right", "up", "down")
	var combat_idle: bool = false
	if !is_heavy_attack and !is_light_attack:
		if anim_dodging:
			animation.play_backwards("Dodge(shadow)")
			await animation.animation_finished
			anim_dodging = false
		elif !is_dodging and !is_guarding and direction:
			animation.play("walk")
			if velocity.x > 10:
				animation.flip_h = true
			elif velocity.x < -10:
				animation.flip_h = false
		elif is_guarding:
			animation.play("guard")
		elif !is_guarding and !is_dodging:
			animation.play("idle")
	elif is_light_attack:
		if combo_count == 0 or combo_count == 3:
			animation.play("light_attack_1")
		elif combo_count == 1:
			animation.play("light_attack_2")
		elif combo_count == 2:
			animation.play("light_attack_3")
	elif is_heavy_attack:
		$Sprite/Effects.show()
		animation.play("Heavy_Final")
		$Sprite/Effects.play("default")
		await animation.animation_finished
		is_heavy_attack = false
	else:
		animation.play("idle")
			
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
	if Input.is_action_just_pressed("RB"):
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
	elif Input.is_action_just_pressed("LB"):
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
	if Input.is_action_just_pressed("jump") or (abs(velocity.x) < 130 and abs(velocity.y) < 150 and not side_dash) or Global.physics_state != Global.gameplay_state.wall_movement:
		Global.GRAVITY = 900
		Global.physics_state = Global.gameplay_state.physics
		exited_wall = true
		#animate()
		test_animate()
			
			
func _combat_mode(delta):
	#Resetting config:
	is_dropdash_charging = false
	is_spindashing_charging = false
	spindash_released= false
	jumping = false
	bouncing_state = false
	bounced = false
	motion = velocity
	#-------------------------------#
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
func _Spring_Jump(delta):
	motion.y = 0
	Global.GRAVITY = 0
	motion.y = -Global.SpringJumpForce * delta
	
func _has_entered_dash_panel(dash_force: Vector2) -> void:
	velocity = dash_force
func _has_entered_boost_ring(dash_force: Vector2) -> void:
	motion = dash_force
	boost_ring = true
	boost_ring_cooldown = 0.2
func _has_entered_dash_pad(dash_force: Vector2) -> void:
	control_lock = true
	motion = dash_force
	await get_tree().create_timer(0.3).timeout
	control_lock = false
	
func _spindash_charge():
	print(speed_charge)
	if !speed_charge_started:
		speed_charge = speed_charge_min
		speed_charge_started = true
	speed_charge = move_toward(speed_charge, speed_charge_max, speed_charge_acc)
