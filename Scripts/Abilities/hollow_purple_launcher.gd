extends Node3D

@export var projectile : PackedScene
@export var leapVelocity : float = 20

var abilityManager : AbilityManager

var onCooldown : bool = false
var isFiring : bool = false
var previousPlayerRotaion : Vector3 ##This variable is used to reorient the player after launching

func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	if event.is_action_pressed("launchAbility") and not isFiring:
		spawnProjectile.rpc()
		
		#var abilityManager : AbilityManager = get_parent()
		#print("Basis: " + str(abilityManager.camera.global_basis.z))
		#print("Trasform: " + str(abilityManager.camera.global_transform.basis.y))
		#
		#hollowPurple.config(abilityManager.camera.global_basis.x)#Input vector 3 here

@rpc("any_peer", "call_local")
func spawnProjectile():
	abilityManager = get_parent()
	
	abilityManager.player.isGravity = false
	abilityManager.player.velocity.y = leapVelocity
	
	var hollowPurple : HollowPurpleProjectile = projectile.instantiate()
	#var hollowPurpl : RigidBody3D
	#hollowPurple.rotation_degrees = abilityManager.camera.global_transform.basis.get_euler()
	#hollowPurple.config(-abilityManager.camera.global_basis.z)
	hollowPurple.transform = transform
	#FIRST PERSON METHOD
	#hollowPurple.linear_velocity = global_transform.basis.z * -1 * hollowPurple.speed
	match abilityManager.player.controlMode:
		abilityManager.player.ControllerType.FIRST_PERSON:
			hollowPurple.linear_velocity = global_transform.basis.z * -1 * hollowPurple.speed
		abilityManager.player.ControllerType.THIRD_PERSON_SHOULDER:
			hollowPurple.linear_velocity = abilityManager.player.thirdPersonShoulderCam.global_transform.basis.z * -1 * hollowPurple.speed
	add_child(hollowPurple, true)
	
	hollowPurple.initalAnimationFinished.connect(hollowPurpleAnimationFinished)
	hollowPurple.config()
	hollowPurple.global_position = global_position
	
	isFiring = true
	previousPlayerRotaion = abilityManager.playerVisuals.rotation
	abilityManager.playerVisuals.look_at(global_transform.basis.z * -1 * hollowPurple.speed) #Make the player look in the direction of the hollow purple

func hollowPurpleAnimationFinished():
	abilityManager.player.isGravity = true
	isFiring = false
	abilityManager.playerVisuals.rotation = previousPlayerRotaion
