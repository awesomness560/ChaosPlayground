extends CharacterBody3D
class_name Player

enum ControllerType {FIRST_PERSON, THIRD_PERSON, THIRD_PERSON_SHOULDER}

@export var JUMP_VELOCITY = 10
@export var sensivity = 0.3
@export var gravity : float = 9.8
var fov = false
var lerp_speed= 1
@export var controlMode : ControllerType : set = matchCurrentCamera
@export var offsetThirdPerson : Vector3
@export_group("Speed")
var SPEED = 5.0
@export var walkingSpeed : float = 20
@export var runningSpeed : float = 15

#Third Person Variables
var snapVector : Vector3 = Vector3.DOWN
var lockBody : bool = false

@export_group("Third Person Shoulder")
@export var sensHorizontal : float = 0.5
@export var sensVetical : float = 0.5

@export_group("References")
@export var firstPersonCamera : Camera3D
@export var visuals : Node3D
@export var characterAnimator : AnimationPlayer
#@export var thirdPersonCamera : ThirdPersonCamera
@export var usernameLabel : Label
@export_subgroup("Third Person")
@export var thirdPersonCamera : Camera3D
@export var springArm : SpringArm3D
@export_subgroup("Third Person Shoulder")
@export var thirdPersonShoulderCam : Camera3D
@export var camMount : Node3D

var username : String : set = setUsername

var isGravity : bool = true ##Determines if gravity is enabled
var isRunning : bool = false
var isInAir : bool = false

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	matchCurrentCamera(controlMode)
	
	if not is_multiplayer_authority(): return
	
	#camera.current = true
	#thirdPersonCamera.current = true
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func matchCurrentCamera(control : ControllerType):
	controlMode = control
	
	match control:
		ControllerType.FIRST_PERSON:
			firstPersonCamera.current = is_multiplayer_authority()
		ControllerType.THIRD_PERSON:
			thirdPersonCamera.current = is_multiplayer_authority()
			thirdPersonCamera.get_parent_node_3d().global_rotation = firstPersonCamera.global_rotation
		ControllerType.THIRD_PERSON_SHOULDER:
			thirdPersonShoulderCam.current = is_multiplayer_authority()

func _input(event):
	if not is_multiplayer_authority(): return
	
	match controlMode:
		ControllerType.FIRST_PERSON:
			firstPersonInput(event)
		ControllerType.THIRD_PERSON:
			thirdPersonInput(event)
		ControllerType.THIRD_PERSON_SHOULDER:
			thirdPersonShoulderInput(event)
	
	if event.is_action_pressed("Escape"):
		get_tree().quit()

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	
	match controlMode:
		ControllerType.FIRST_PERSON:
			visuals.hide()
			firstPersonMovment(delta)
		ControllerType.THIRD_PERSON:
			visuals.show()
			thirdPersonMovement(delta)
		ControllerType.THIRD_PERSON_SHOULDER:
			visuals.show()
			thirdPersonShoulderMovement(delta)

func _process(delta):
	springArm.position = position + offsetThirdPerson
#func _on_area_3d_body_entered(body):
	#if body.name=="player":
		#get_tree().change_scene_to_file("res://node_3d.tscn")
#
	#pass # Replace with function body.

func thirdPersonShoulderInput(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sensHorizontal))
		if not lockBody:
			visuals.rotate_y(deg_to_rad(event.relative.x * sensHorizontal))
		camMount.rotate_x(deg_to_rad(-event.relative.y * sensVetical))

func thirdPersonShoulderMovement(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if not lockBody:
			visuals.look_at(position + direction)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func thirdPersonInput(event):
	pass
	#if event is InputEventMouseMotion:
		#rotate_y(deg_to_rad(-event.relative.x * sensivity))
		#visuals.rotate_y(deg_to_rad(event.relative.x * sensivity))

func thirdPersonMovement(delta):
	var moveDirection : Vector3 = Vector3.ZERO
	moveDirection.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	moveDirection.z = Input.get_action_strength("back") - Input.get_action_strength("forward")
	moveDirection = moveDirection.rotated(Vector3.UP, springArm.rotation.y).normalized() #Makes move direction relative to the camera
	
	velocity.x = moveDirection.x * SPEED
	velocity.z = moveDirection.z * SPEED
	if isGravity:
		velocity.y -= gravity * delta
	elif not velocity.y < 0:
		velocity.y -= gravity * delta
	
	var justLanded : bool = is_on_floor() and snapVector == Vector3.ZERO
	var isJumping : bool = is_on_floor() and Input.is_action_just_pressed("jump")
	if isJumping:
		velocity.y = JUMP_VELOCITY
		snapVector = Vector3.ZERO
	elif justLanded:
		snapVector = Vector3.DOWN
	floor_snap_length = snapVector.y
	move_and_slide()
	
	#if velocity.length() > 0.2:
		#var lookDirection = Vector2(velocity.z, velocity.x)
		#visuals.rotation.y = lookDirection.angle()

func firstPersonInput(event):
	if event is InputEventMouseMotion:
		firstPersonCamera.rotation_degrees.x -= event.relative.y * sensivity
		firstPersonCamera.rotation_degrees.x = clamp(firstPersonCamera.rotation_degrees.x, -90, 90)
		rotation_degrees.y -= event.relative.x * sensivity

func firstPersonMovment(delta):
	if is_on_floor():
		isInAir = false
	# Add the gravity.
	if not is_on_floor() and isGravity:
		velocity.y -= gravity * delta
		
	#print(characterAnimator.current_animation)
	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		characterAnimator.play("falling")
		isInAir = true
	if Input.is_action_pressed("RUN"):
		firstPersonCamera.fov +=2
		firstPersonCamera.fov = clamp(firstPersonCamera.fov,85,110)
		SPEED = runningSpeed
		isRunning = true
	if  Input.is_action_just_released("RUN"): #HACK: The POV snaps back to normal. I might want to tween insteads
		firstPersonCamera.fov = 85
		SPEED = walkingSpeed
		isRunning = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if isRunning:
			if not characterAnimator.current_animation == "running" and not isInAir:
				characterAnimator.play("running")
		else:
			if not characterAnimator.current_animation == "walking" and not isInAir:
				characterAnimator.play("walking")
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		if not characterAnimator.current_animation == "idle" and not isInAir:
			characterAnimator.play("idle")
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func setUsername(userName : String):
	usernameLabel.text = userName
