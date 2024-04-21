extends Node
class_name DamageModule


func damage(bodyToDamage : Node3D, damageAmount : float):
	if bodyToDamage.is_in_group("player") or bodyToDamage.is_in_group("health"):
		var healthModule : HealthModule = bodyToDamage.get_node("HealthModule")
		healthModule.takeDamage(damageAmount)
