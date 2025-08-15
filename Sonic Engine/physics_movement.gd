extends State
var motion := Vector2(0.0,0.0)
@onready var player = $"../.."
@onready var animation = $"../../AnimationPlayer"
var floor_angle: float
var rot := 0.0
var slope_factor: float
const acc := 1

var control_lock: bool = false
var facing_direction_lock: bool = false
var direction: float

var jumpcount: int = 0
var jumping: bool = false
var jumpAnimStart: bool = false
var JUMP_VELOCITY = 13

var bounced: bool = false
var bouncing_state: bool = false
var is_bouncing: bool = false
var bounce_fall_velocity: float = -45
var bounce_velocity: float = -20

var grounded: bool = true
var facing_direction: Vector2
var last_facing_direction: Vector2

var got_down: bool = false

var is_dropdash_charging: bool = false
var dropdash_released: bool = true
var is_spindashing_charging: bool = false
var spindash_released: bool = false
var is_slope_dash: bool = false
var speed_charge: float = 0
@export var speed_charge_min: float = 6
@export var speed_charge_max: float = 50
@export var speed_charge_acc: float = 2

@onready var wallcast := $"../../WallCast"
# Acceleration. Default: 2
# This is what moves you forward.

const dec := 1.0
# Deccelleration. Default: 30.0
## This is only used when you try to turn around.

const topspeed := 17
# Top Speed. Default: 300.0
## You won't be able to Accelerate past this point without some Momentum.
var GRAVITY = 20

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	direction = Input.get_axis("Left", "Right") # Emits "-1" if holding left, and "1" if holding right.
	var is_on_surface: bool = player.is_on_floor() or player.is_on_wall() or player.is_on_ceiling()
	var directionY = Input.get_axis("Down", "Up")
	var upside_factor := 1
	print(motion.x)
	if player.is_on_floor():
		player.up_direction.y = player.get_floor_normal().y
		jumpcount = 0
		jumping = false
#-------------------------JUMPING-------------------------------

		if Input.is_action_just_pressed("Jump"):
			jumping = true
		if jumping:
			$"../../SlopeJumpTimer".start()
			jumpAnimStart = true
			jumping = true
			motion = JUMP_VELOCITY * delta * 130 * Vector2(player.get_floor_normal().x,player.get_floor_normal().y)
			jumpcount += 1
	if !player.is_on_floor():
		if not $"../../Collision/RayCast3D".is_colliding() and grounded:
			grounded = false
			motion = Vector2(player.get_real_velocity().x,player.get_real_velocity().y)
			rot = 0
			player.up_direction = Vector3(0, -1, 0)
	if Input.is_action_just_pressed("Jump") and !player.is_on_floor() and jumpcount < 2:
			motion.x = motion.x
			motion.y = JUMP_VELOCITY * delta * 120
			jumpcount += 1
	if jumping and motion.y > 0: # If your jumping motion goes beyond a certain point...
		if Input.is_action_just_released("Jump") and jumpcount < 2: # ...but you're NOT pressing the jump button anymore...
			motion.y = JUMP_VELOCITY / 3

#----------------------------------------------BOUNCE--------------------------------------------------

	if !player.is_on_floor() and (jumping or jumpcount >= 1) and Input.is_action_just_pressed("Exit"):
		bounced = false
		is_bouncing = true
		bouncing_state = true
		if bouncing_state:
			motion = Vector2(motion.x, bounce_fall_velocity * 1.2) * delta * 60
	if player.is_on_floor() and bouncing_state and !bounced:
		jumpcount += 1
		motion.y = 0
		motion = Vector2(motion.x * 5, -bounce_velocity * 1.2) * delta * 60
	if motion.y > 0 and bouncing_state:
		bounced = true
		bouncing_state = false
	if motion.y <= 0 and player.is_on_floor():
		bounced = false
		is_bouncing = false

#----------------------------------------SPINDASH & DROPDASH-------------------------------------------
	if Input.is_action_just_pressed("Action1") and !spindash_released:
		if player.is_on_floor() and got_down:
			is_spindashing_charging = true
			speed_charge += 5
		elif !player.is_on_floor():
			is_dropdash_charging = true
			speed_charge += 5
	if (Input.is_action_just_released("Action1") and is_spindashing_charging) or (is_dropdash_charging and player.is_on_floor() and !spindash_released ) or (((player.get_floor_normal().x > 0.6 and sign(facing_direction.x) > 0) or (player.get_floor_normal().x < -0.6 and sign(facing_direction.x) < 0)) and got_down):
		if is_spindashing_charging or is_dropdash_charging:
			motion.x = speed_charge * sign(facing_direction.x)
		elif !is_spindashing_charging and !is_dropdash_charging:
			motion.x = motion.x
			is_slope_dash = true
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
		if (Input.is_action_just_pressed("Jump") or Input.is_action_just_pressed("Action1")) or ((abs(motion.x) < 5)):
			speed_charge = 0
			control_lock = false
			spindash_released = false
			is_slope_dash = false


#------------------------------------SPRITE & COLLISION ROTATION---------------------------------------

	if player.get_floor_normal().x >= 0:
		$"../../Sprite3D".rotation.z = lerp_angle($"../../Sprite3D".rotation.z, -rot, 0.25)
		$"../../Sprite3D".rotation.y = 0
		$"../../Collision".rotation.z = -rot
		$"../../Collision".rotation.y = 0
	if player.get_floor_normal().x < 0:
		$"../../Sprite3D".rotation.z = lerp_angle($"../../Sprite3D".rotation.z, rot, 0.25)
		$"../../Sprite3D".rotation.y = 0
		$"../../Collision".rotation.z = rot
		$"../../Collision".rotation.y = 0
	## This ensures consistency when running along slopes.
	# Smoothly Interpolate your Sprite's rotation with the floor, somewhat similarly to Sonic Mania.
	
	if player.get_floor_normal().y < 0:
		upside_factor = 1
	elif player.get_floor_normal().y >= 0:
		upside_factor = 1
#--------------------------------DEFINING MOTION---------------------------------
	if is_on_surface:
		floor_angle = player.get_floor_angle()
		slope_factor = cos(floor_angle)
	rot = floor_angle
	player.velocity.x =  motion.x * (1 + -0.5 * player.get_floor_normal().x)
	player.velocity.y = motion.y * (1 + -0.5 * player.get_floor_normal().y)
#--------------------------------MOVEMENT.X---------------------------------------
	if direction and !control_lock: # If holding left or right, and not slipping down a slope...
		if is_on_surface: # If touching the floor...
			if (direction > 0 and motion.x >= 0) or (direction < 0 and motion.x <= 0): # If you're holding in the direction you're moving...
				if abs(motion.x) <= topspeed: # If you're not over your Top Speed...
					motion.x +=  acc * 0.25 * direction
					# Accelerate in the direction you're holding.
				else: # If you're not over your Top Speed...
					motion.x =  topspeed * direction
			else:
				if abs(motion.x) > 2.0 or abs(motion.x) < 1.0:
					motion.x += 0.25 * direction * delta * 120
				elif abs(motion.x) <= 2.0 and abs(motion.x) >= 1.0:
					motion.x += 0.1 * direction * delta * 120
		else: # If mid-air...
			if abs(slope_factor) < 0.7:
				motion.x += (acc * 0.5) * direction * delta * 60
			else:
				if (direction >= 0 and motion.x >= 0) or (direction <= 0 and motion.x <= 0) : # If you're holding in the direction you're moving...
					if abs(motion.x) <= topspeed: # If you're not over your Top Speed...
						motion.x += (acc) * direction * delta * 60
						# Accelerate (a bit faster) in the direction you're holding.
				else:  # If you're trying to turn around...
					motion.x += (acc) * direction * delta * 120
					# Deccellerate at the same speed.
	else: # If not pressing anything...
		if is_on_surface and abs(slope_factor) > 0.95: # If you're on flat, or near-flat ground...
			motion.x = move_toward(motion.x, 0, acc * 0.25)
			# Slow to a stop.
			## We shouldn't be able to stand perfectly still on a steep slope, right? Right.
	if player.is_on_floor() and not wallcast.is_colliding() and slope_factor < 0.8 and !bouncing_state and !bounced and motion.y == 0:
		facing_direction_lock = true
		if facing_direction == Vector2.RIGHT:
			motion.x += 0.25 * (acc) * (1 - slope_factor)
		elif facing_direction == Vector2.LEFT:
			motion.x -= 0.25 * (acc) * (1 - slope_factor)
	elif player.is_on_floor() and wallcast.is_colliding() and slope_factor < 0.8 and !bouncing_state and !bounced and motion.y == 0:
		facing_direction_lock = true
		if facing_direction == Vector2.RIGHT:
			motion.x -= 0.5 * (acc*0.75) * (1 - slope_factor)
			if is_slope_dash:
				print("WRONGWAY")
		elif facing_direction == Vector2.LEFT:
			motion.x += 0.5 * (acc*0.75) * (1 - slope_factor)
			if is_slope_dash:
				print("WRONGWAY")
	if slope_factor >= 0.8:
		facing_direction_lock = false

#------------------------------GRAVITY-------------------------------------------------

	if !player.is_on_floor():
		$"../../Sprite3D".rotation.z = 0
		$"../../Sprite3D".rotation.y = 0
		$"../../Collision".rotation.z = 0
		$"../../Collision".rotation.y = 0
		motion.y -= GRAVITY * delta *0.01
	else:
		if abs(slope_factor) < 0.65 and !jumping and !(bouncing_state or bounced): # If running up a perfectly vertical wall...
			motion.y = 0
			# This makes sure you don't get any unwanted horizontal air speed when- 
			# -riding a perfectly U-shaped crevice. (Most of the time, at least.)
			# Without this, the motion addition below would cause you to drift off to-
			# -the side after launching yourself upwards.

	player.move_and_slide()
	animate()

func animate():
	var started_jump_anim: bool = false
	var directionX = Input.get_axis("Left", "Right") # Emits "-1" if holding left, and "1" if holding right.
	var directionY = Input.get_axis("Down", "Up")
	var turning: bool = false
#----------------------------------------SPRITE FLIP-----------------------------------------
	if !control_lock and !facing_direction_lock:
		if directionX < -0.1:
			facing_direction = Vector2.LEFT
			last_facing_direction = Vector2.LEFT
		elif directionX > 0.1:
			facing_direction = Vector2.RIGHT
			last_facing_direction = Vector2.RIGHT
		elif directionX >= -0.1 and directionX <= 0.1:
			facing_direction = last_facing_direction
	if sign(directionX) == sign(motion.x) and !facing_direction_lock:
		if facing_direction == Vector2.RIGHT and !turning:
			wallcast.rotation = Vector3(0.0,0.0,PI/2)
			$"../../Sprite3D".flip_h = false
		elif facing_direction == Vector2.LEFT and !turning:
			wallcast.rotation = Vector3(0.0,0.0,-PI/2)
			$"../../Sprite3D".flip_h = true
	elif sign(directionX) != sign(motion.x) or facing_direction_lock:
		if motion.x >= 0:
			$"../../Sprite3D".flip_h = false
		elif motion.x <= 0:
			$"../../Sprite3D".flip_h = true
#--------------------------------------------JUMPING ANIM-----------------------------------------
	if jumping and jumpAnimStart and !started_jump_anim and !is_dropdash_charging and !is_spindashing_charging and !spindash_released:
		animation.play("JumpSquat")
		$"../../AnimationPlayer".speed_scale = 1 + (abs(motion.x) / 20)
		await animation.animation_finished
		jumpAnimStart = false
	if jumping and !jumpAnimStart or bounced and !is_dropdash_charging and !is_spindashing_charging and !spindash_released:
		if player.is_on_floor() and slope_factor < 0.92:
			animation.play("Running")
		else:
			animation.play("JumpLoop")
		$"../../AnimationPlayer".speed_scale = 1 + (abs(motion.x) / 80)
#-------------------------------------------SPINDASH ANIM-----------------------------------------
	if is_dropdash_charging or is_spindashing_charging:
		animation.speed_scale = 1
		if facing_direction == Vector2.RIGHT:
			$"../../Sprite3D".flip_h = false
		elif facing_direction == Vector2.LEFT:
			$"../../Sprite3D".flip_h = true
		animation.play("SpinDash_Charge")
		$"../../Sprite3D".offset.y = -7.5
	elif spindash_released:
		animation.speed_scale = 1
		animation.play("SpinDash_Release")
		$"../../Sprite3D".offset.y = -7.5
	else:
		if animation.current_animation != "SpinDash_Release":
			$"../../Sprite3D".offset.y = 0
#-------------------------------------WALKING, RUNNING, IDLE ANIMS--------------------------------
	if (player.is_on_floor() or $"../../Collision/RayCast3D".is_colliding()) and !bouncing_state and !bounced and !spindash_released and !is_spindashing_charging:
		if abs(motion.x) <= 0.5 and slope_factor > 0.92 and !turning:
			animation.speed_scale = 1
			if Input.get_axis("Down", "Up") < -0.4 and abs(motion.x) < 0.5:
				if !got_down:
					animation.play("GetDown")
					got_down = true
			else:
				animation.play("Idle")
				got_down = false
		if ((directionX > 0 and motion.x >= 0) or (directionX < 0 and motion.x <= 0)) or (slope_factor < 0.92 and sign(directionX) != sign(motion.x)):
				if abs(motion.x) > 0.5 and abs(motion.x) < 14 and !got_down:
					animation.play("Walking")
					animation.speed_scale = 0.5 + (abs(motion.x) / 20)
				elif abs(motion.x) >= 15:
					animation.play("Running")
					animation.speed_scale = 1 + (abs(motion.x) / 20)
		#elif ((directionX < 0 and motion.x >= 0) or (directionX > 0 and motion.x <= 0) or (abs(motion.x) > 5.0 and directionX == 0)) and slope_factor > 0.92:
			#if abs(motion.x) <= 2.0:
				#turning = true
				#animation.play("RunTurn")
				#await animation.animation_finished
				#print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
				#turning = false
		elif sign(directionX) != sign(motion.x):
			if abs(motion.x) > 9.0:
				animation.play("Stopping")
		if Input.get_axis("Down", "Up") < -0.4:
			got_down = true
		elif Input.get_axis("Down", "Up") >= -0.4:
			got_down = false
func _spindash_charge():
	if speed_charge <= speed_charge_max:
		speed_charge = move_toward(speed_charge, speed_charge_max, 0.4)
