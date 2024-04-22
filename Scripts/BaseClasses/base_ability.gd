extends Node3D
class_name BaseAbility

signal cooldownTime(time : float)

var timerCompleted : bool = true ##Internal BaseAbility variable for managing the timer
var isSelected : bool = false : set = select ##Use this variable to decide how ability acts when selected or not

var abilityManager : AbilityManager
var abilityHud : AbilityHudTemplate ##A reference to the hud template for when it is selected or not
var abilityResourceBase : BaseAbilityResource : set = setToResource
@export var cooldownTimer : Timer ##Reference to the cooldown timer

func setToResource(resource : BaseAbilityResource):
	assert(false, "Ability did not override the setToResource() function")

func config():
	abilityManager = get_parent()
	assert(false, "Ability did not override the config() function")

func checkCooldownTime():
	var percentOfTimeLeft : float
	if cooldownTimer.time_left > 0:
		percentOfTimeLeft = 1 - cooldownTimer.time_left / cooldownTimer.wait_time
		cooldownTime.emit(percentOfTimeLeft)
		timerCompleted = false
	elif timerCompleted == false:
		cooldownTime.emit(1)
		timerCompleted = true

func select(status : bool):
	isSelected = status
	if abilityManager.player.is_multiplayer_authority():
		abilityHud.abilityActiveStatus(status)
