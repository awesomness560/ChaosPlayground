extends Node3D

@export var projectile : PackedScene

var abilityManager : AbilityManager

func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	if event.is_action_pressed("launchAbility"):
		spawnProjectile.rpc()
		
		#var abilityManager : AbilityManager = get_parent()
		#print("Basis: " + str(abilityManager.camera.global_basis.z))
		#print("Trasform: " + str(abilityManager.camera.global_transform.basis.y))
		#
		#hollowPurple.config(abilityManager.camera.global_basis.x)#Input vector 3 here

@rpc("any_peer", "call_local")
func spawnProjectile():
	abilityManager = get_parent()
	var hollowPurple : Node3D = projectile.instantiate()
	#var hollowPurpl : RigidBody3D
	#hollowPurple.rotation_degrees = abilityManager.camera.global_transform.basis.get_euler()
	#hollowPurple.config(-abilityManager.camera.global_basis.z)
	hollowPurple.transform = transform
	hollowPurple.linear_velocity = global_transform.basis.z * -1 * hollowPurple.speed
	hollowPurple.config()
	add_child(hollowPurple, true)
	hollowPurple.global_position = global_position
	
