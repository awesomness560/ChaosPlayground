extends BaseAbility

@export var projectile : PackedScene
@export var leapVelocity : float = 20 ##How high you jump when you use the ability

var abilityResource : HollowPurpleResource

var onCooldown : bool = false
var isFiring : bool = false
var previousPlayerRotaion : Vector3 ##This variable is used to reorient the player after launching

func _process(delta):
	checkCooldownTime()

func config():
	abilityManager = get_parent()

func setToResource(resource : BaseAbilityResource):
	abilityResource = resource
	cooldownTimer.wait_time = abilityResource.cooldown

func _unhandled_input(event):
	if not abilityManager.player.is_multiplayer_authority(): return
	if event.is_action_pressed("launchAbility") and not isFiring and not onCooldown and isSelected:
		spawnProjectile.rpc()
		
		#var abilityManager : AbilityManager = get_parent()
		#print("Basis: " + str(abilityManager.camera.global_basis.z))
		#print("Trasform: " + str(abilityManager.camera.global_transform.basis.y))
		#
		#hollowPurple.config(abilityManager.camera.global_basis.x)#Input vector 3 here

func configHollowPurpleProjectile(hollowPurple : HollowPurpleProjectile):
	hollowPurple.speed = abilityResource.speed
	hollowPurple.damage = abilityResource.damage
	hollowPurple.abilityManager = abilityManager

@rpc("any_peer", "call_local")
func spawnProjectile():
	#abilityManager = get_parent()
	
	
	abilityManager.player.isGravity = false
	abilityManager.player.velocity.y = leapVelocity
	
	var hollowPurple : HollowPurpleProjectile = projectile.instantiate()
	configHollowPurpleProjectile(hollowPurple)
	#var hollowPurpl : RigidBody3D
	#hollowPurple.rotation_degrees = abilityManager.camera.global_transform.basis.get_euler()
	#hollowPurple.config(-abilityManager.camera.global_basis.z)
	hollowPurple.transform = transform
	
	match abilityManager.player.controlMode:
		abilityManager.player.ControllerType.FIRST_PERSON:
			hollowPurple.linear_velocity = global_transform.basis.z * -1 * hollowPurple.speed
		abilityManager.player.ControllerType.THIRD_PERSON_SHOULDER:
			hollowPurple.linear_velocity = abilityManager.player.thirdPersonShoulderCam.global_transform.basis.z * -1 * hollowPurple.speed
	#FIRST PERSON METHOD
	#hollowPurple.linear_velocity = global_transform.basis.z * -1 * hollowPurple.speed
	add_child(hollowPurple, true)
	
	hollowPurple.initalAnimationFinished.connect(hollowPurpleAnimationFinished)
	hollowPurple.config()
	hollowPurple.global_position = global_position
	
	isFiring = true
	abilityManager.isLocked = true
	previousPlayerRotaion = abilityManager.playerVisuals.rotation
	abilityManager.playerVisuals.look_at(global_transform.basis.z * -1 * hollowPurple.speed) #Make the player look in the direction of the hollow purple

func hollowPurpleAnimationFinished():
	abilityManager.player.isGravity = true
	isFiring = false
	abilityManager.playerVisuals.rotation = previousPlayerRotaion
	#Setting cooldown
	onCooldown = true
	cooldownTimer.start()
	abilityManager.isLocked = false


func _on_cooldown_timeout():
	onCooldown = false
