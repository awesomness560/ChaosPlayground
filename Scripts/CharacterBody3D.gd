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
@export var hudScene : PackedScene
var hud : HUD
@export var firstPersonCamera : Camera3D
@export var visuals : Node3D
@export var threeDmodel : Node3D
@export var characterAnimator : AnimationPlayer
@export var spawnCamera : SpawnCamera
#@export var thirdPersonCamera : ThirdPersonCamera
@export var usernameLabel : Label
@export_subgroup("FirstPerson")
@export var firstPersonController : FirstPersonController
@export_subgroup("Third Person")
@export var thirdPersonCamera : Camera3D
@export var springArm : SpringArm3D
@export_subgroup("Third Person Shoulder")
@export var thirdPersonShoulderCam : Camera3D
@export var camMount : Node3D
@export_subgroup("Modules")
@export var healthModule : HealthModule

var username : String : set = setUsername
var initalCollisionLayer : int
var initialCollisionMask : int

var isGravity : bool = true ##Determines if gravity is enabled
var isRunning : bool = false
var isInAir : bool = false
var isPaused : bool = false : set = setPause

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	#print("in peer ", multiplayer.get_unique_id(), ", player ", name, " is owned by: ", get_multiplayer_authority())
	#spawnCamera = GlobalVars.spawnCamera
	matchCurrentCamera(controlMode)
	
	#Make you invisible and untouchable while you respawn
	initalCollisionLayer = collision_layer
	initialCollisionMask = collision_mask
	
	setCollisionLayer(false)
	isGravity = false
	#visuals.hide()
	
	#if not MultiplayerManager.players == 1:
		#rpc("matchCurrentCamera", controlMode)
	#spawnCamera.setCurrent(self, false)
	
	if not is_multiplayer_authority(): return
	
	var HUD = hudScene.instantiate()
	hud = HUD
	hud.hide()
	add_child(HUD)
	
	#camera.current = true
	#thirdPersonCamera.current = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	spawnCamera.setCurrent(self, true)
	#spawnCamera.player = self
	#spawnCamera.make_current()
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func setPause(state : bool): ##Toggles the first person controller with pause menu
	isPaused = state
	firstPersonController.isCurrent = not state

@rpc("any_peer", "call_local")
func spawn(spawnPosition : Vector3):
	healthModule.restoreHealth()
	global_position = spawnPosition #TODO: I can put the spawn animation here
	
	deadState(false)
	#spawnCamera.setCurrent(self, false)
	matchCurrentCamera(controlMode)
	#setCollisionLayer(true)
	#isGravity = true
	#visuals.visible = true

@rpc("any_peer", "call_local")
func matchCurrentCamera(control : ControllerType):
	controlMode = control
	
	match control:
		ControllerType.FIRST_PERSON:
			firstPersonController.setCam(is_multiplayer_authority())
			#firstPersonCamera.current = is_multiplayer_authority()
		ControllerType.THIRD_PERSON:
			thirdPersonCamera.current = is_multiplayer_authority()
			thirdPersonCamera.get_parent_node_3d().global_rotation = firstPersonCamera.global_rotation
		ControllerType.THIRD_PERSON_SHOULDER:
			thirdPersonShoulderCam.current = is_multiplayer_authority()

func _input(event):
	if not is_multiplayer_authority() or isPaused: return
	
	match controlMode:
		#ControllerType.FIRST_PERSON:
			#firstPersonInput(event)
		ControllerType.THIRD_PERSON:
			thirdPersonInput(event)
		ControllerType.THIRD_PERSON_SHOULDER:
			thirdPersonShoulderInput(event)
	
	if event.is_action_pressed("Escape"):
		get_tree().quit()

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	
	if not is_on_floor() and isGravity:
		velocity.y -= gravity * delta
	
	if isGravity:
		velocity.y -= gravity * delta
	elif not velocity.y < 0:
		velocity.y -= gravity * delta
	
	if not isPaused:
		match controlMode:
			ControllerType.FIRST_PERSON:
				threeDmodel.hide()
				firstPersonController.isCurrent = true
				#firstPersonMovment(delta)
			ControllerType.THIRD_PERSON:
				threeDmodel.show()
				thirdPersonMovement(delta)
				firstPersonController.isCurrent = false
			ControllerType.THIRD_PERSON_SHOULDER:
				threeDmodel.show()
				thirdPersonShoulderMovement(delta)
				firstPersonController.isCurrent = false
	
	move_and_slide()

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
	
	var justLanded : bool = is_on_floor() and snapVector == Vector3.ZERO
	var isJumping : bool = is_on_floor() and Input.is_action_just_pressed("jump")
	if isJumping:
		velocity.y = JUMP_VELOCITY
		snapVector = Vector3.ZERO
	elif justLanded:
		snapVector = Vector3.DOWN
	floor_snap_length = snapVector.y
	
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
	#if not is_on_floor() and isGravity:
		#velocity.y -= gravity * delta
		
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
	var input_dir = Input.get_vector("left", "right", "forward", "back")
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


func setUsername(userName : String):
	usernameLabel.text = userName


func _on_health_module_died():
	if is_multiplayer_authority():
		deadState(true)

func deadState(state : bool):
	spawnCamera.setCurrent(self, state)
	setCollisionLayer(not state)
	isGravity = not state
	visuals.visible = not state
	if is_multiplayer_authority():
		hud.visible = not state

func setCollisionLayer(state : bool):
	if state:
		collision_layer = initalCollisionLayer
		collision_mask = initialCollisionMask
	else:
		collision_layer = 0
		collision_mask = 0
