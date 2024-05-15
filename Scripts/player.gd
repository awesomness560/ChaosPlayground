extends Node3D
class_name FirstPersonController

@export var BUNNY_HOP_ACCELERATION = 0.1
@export_group("Speed")
@export var JUMP_VELOCITY = 4.5 ##How high you jump
@export var WALKING_SPEED = 5.0
@export var SPRINTING_SPEED = 8.0
@export var CROUCHING_SPEED = 3.0
@export var CROUCHING_DEPTH = -0.9 ##How far the camera goes down
@export var SLIDING_SPEED = 5.0
@export_group("FOV")
@export var slidingFOV : float = 85
@export var sprintingFOV : float = 95
@export var walkingFOV : float = 75
@export var crouchingFOV : float = 65
@export_group("Sensitivity")
@export var MOUSE_SENS = 0.25
@export var LERP_SPEED = 10.0
@export var AIR_LERP_SPEED = 6.0 ##How fast we move in the air without input
@export var FREE_LOOK_TILT_AMOUNT = 5.0 ##The tilt in free look mode (Press I)
@export_group("Wiggle")
@export_subgroup("Wiggle Threshold")
@export var WIGGLE_ON_WALKING_SPEED = 14.0
@export var WIGGLE_ON_SPRINTING_SPEED = 22.0
@export var WIGGLE_ON_CROUCHING_SPEED = 10.0
@export var rollThreshold : float = -7.9
@export_subgroup("Wiggle Intensity")
@export var WIGGLE_ON_WALKING_INTENSITY = 0.1
@export var WIGGLE_ON_SPRINTING_INTENSITY = 0.2
@export var WIGGLE_ON_CROUCHING_INTENSITY = 0.05
@export_group("References")
@export var player : CharacterBody3D
@export var neck : Node3D
@export var head : Node3D
@export var eyes : Node3D
@export var animationPlayer : AnimationPlayer
@export var thirdPersonAnimations : AnimationPlayer
@export var raycast : RayCast3D
@export var camera : Camera3D
@export var slidingTimer : Timer
@export var standingCollision : CollisionShape3D
@export var crouchingCollision : CollisionShape3D

var isCurrent : bool = false

var current_speed = 5.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var direction = Vector3.ZERO
var is_walking = false
var is_sprinting = false
var is_crouching = false
var is_free_looking = false
var slide_vector = Vector2.ZERO
var wiggle_vector = Vector2.ZERO
var wiggle_index = 0.0
var wiggle_current_intensity = 0.0
var bunny_hop_speed = SPRINTING_SPEED
var last_velocity = Vector3.ZERO
var stand_after_roll = false

enum state {SPRINTING, WALKING, SLIDING, CROUCHING}

var movementState : state ##Contains the current state

#func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	if event is InputEventMouseMotion and isCurrent:
		if is_free_looking:
			neck.rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENS))
			neck.rotation.y = clamp(neck.rotation.y, deg_to_rad(-120), deg_to_rad(120))
		else:
			rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENS))
		head.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENS))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))


func _physics_process(delta):
	if not isCurrent : return
	
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	
	if stand_after_roll:
		head.position.y = lerp(head.position.y, 0.0, delta * LERP_SPEED)
		standingCollision.disabled = true
		crouchingCollision.disabled = false
		stand_after_roll = false
	
	if Input.is_action_pressed("crouch") or raycast.is_colliding():
		if player.is_on_floor():
			current_speed = lerp(current_speed, CROUCHING_SPEED, delta * LERP_SPEED)
		head.position.y = lerp(head.position.y, CROUCHING_DEPTH, delta * LERP_SPEED)
		standingCollision.disabled = true
		crouchingCollision.disabled = false
		wiggle_current_intensity = WIGGLE_ON_CROUCHING_INTENSITY
		wiggle_index += WIGGLE_ON_CROUCHING_SPEED * delta
		movementState = state.CROUCHING
		
		if is_sprinting and input_dir != Vector2.ZERO and player.is_on_floor():
			slidingTimer.start()
			slide_vector = input_dir
			movementState = state.SLIDING
		elif !Input.is_action_pressed("RUN"):
			slidingTimer.stop()
		is_walking = false
		is_sprinting = false
		is_crouching = true
	else:
		head.position.y = lerp(head.position.y, 0.0, delta * LERP_SPEED)
		standingCollision.disabled = false
		crouchingCollision.disabled = true
		slidingTimer.stop()
		if Input.is_action_pressed("RUN"):
			if !Input.is_action_pressed("jump"):
				bunny_hop_speed = SPRINTING_SPEED
			current_speed = lerp(current_speed, bunny_hop_speed, delta * LERP_SPEED)
			wiggle_current_intensity = WIGGLE_ON_SPRINTING_INTENSITY
			wiggle_index += WIGGLE_ON_SPRINTING_SPEED * delta
			is_walking = false
			is_sprinting = true
			is_crouching = false
			thirdPersonAnimations.play("running")
			movementState = state.SPRINTING
		else:
			current_speed = lerp(current_speed, WALKING_SPEED, delta * LERP_SPEED)
			wiggle_current_intensity = WIGGLE_ON_WALKING_INTENSITY
			wiggle_index += WIGGLE_ON_WALKING_SPEED * delta
			is_walking = true
			is_sprinting = false
			is_crouching = false
			thirdPersonAnimations.play("walking")
			movementState = state.WALKING
	
	if Input.is_action_pressed("free_look") or !slidingTimer.is_stopped():
		is_free_looking = true
		if slidingTimer.is_stopped():
			eyes.rotation.z = -deg_to_rad(
				neck.rotation.y * FREE_LOOK_TILT_AMOUNT
			)
		else:
			eyes.rotation.z = lerp(
				eyes.rotation.z,
				deg_to_rad(4.0), 
				delta * LERP_SPEED
			)
	else:
		is_free_looking = false
		rotation.y += neck.rotation.y
		neck.rotation.y = 0
		eyes.rotation.z = lerp(
			eyes.rotation.z,
			0.0,
			delta*LERP_SPEED
		)
	
	if not player.is_on_floor():
		thirdPersonAnimations.play("falling")
		#player.velocity.y -= gravity * delta
		pass
	elif slidingTimer.is_stopped() and input_dir != Vector2.ZERO:
		wiggle_vector.y = sin(wiggle_index)
		wiggle_vector.x = sin(wiggle_index / 2) + 0.5
		eyes.position.y = lerp(
			eyes.position.y,
			wiggle_vector.y * (wiggle_current_intensity / 2.0), 
			delta * LERP_SPEED
		)
		eyes.position.x = lerp(
			eyes.position.x,
			wiggle_vector.x * wiggle_current_intensity, 
			delta * LERP_SPEED
		)
	else:
		eyes.position.y = lerp(eyes.position.y, 0.0, delta * LERP_SPEED)
		eyes.position.x = lerp(eyes.position.x, 0.0, delta * LERP_SPEED)
		if last_velocity.y <= rollThreshold:
			head.position.y = lerp(head.position.y, CROUCHING_DEPTH, delta * LERP_SPEED)
			standingCollision.disabled = false
			crouchingCollision.disabled = true
			animationPlayer.play("roll")
		elif last_velocity.y <= -5.0:
			animationPlayer.play("landing")
	
	if Input.is_action_pressed("jump") and player.is_on_floor():
		animationPlayer.play("jump")
		if !slidingTimer.is_stopped():
			player.velocity.y = JUMP_VELOCITY * 1.5
			slidingTimer.stop()
		else:
			player.velocity.y = JUMP_VELOCITY
		if is_sprinting:
			bunny_hop_speed += BUNNY_HOP_ACCELERATION
		else:
			bunny_hop_speed = SPRINTING_SPEED
	
	if slidingTimer.is_stopped():
		if player.is_on_floor():
			direction = lerp(
				direction,
				(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),
				delta * LERP_SPEED
			)
		elif input_dir != Vector2.ZERO:
			direction = lerp(
				direction,
				(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),
				delta * AIR_LERP_SPEED
			)
	else:
		direction = (transform.basis * Vector3(slide_vector.x, 0.0, slide_vector.y)).normalized()
		current_speed = (slidingTimer.time_left / slidingTimer.wait_time + 0.5) * SLIDING_SPEED
	
	current_speed = clamp(current_speed, 3.0, 12.0)
	
	if direction:
		player.velocity.x = direction.x * current_speed
		player.velocity.z = direction.z * current_speed
	else:
		thirdPersonAnimations.play("idle")
		player.velocity.x = move_toward(player.velocity.x, 0, current_speed)
		player.velocity.z = move_toward(player.velocity.z, 0, current_speed)
	
	last_velocity = player.velocity
	update_camera_fov()
	
	player.move_and_slide()

func update_camera_fov():
	match movementState:
		state.SPRINTING:
			camera.fov = lerp(camera.fov, sprintingFOV, 0.3)
		state.WALKING:
			camera.fov = lerp(camera.fov, walkingFOV, 0.3)
		state.SLIDING:
			camera.fov = lerp(camera.fov, slidingFOV, 0.3)
		state.CROUCHING:
			camera.fov = lerp(camera.fov, crouchingFOV, 0.3)


func _on_sliding_timer_timeout():
	is_free_looking = false


func _on_animation_player_animation_finished(anim_name):
	stand_after_roll = anim_name == 'roll' and !is_crouching

func setCam(current : bool):
	camera.current = current
