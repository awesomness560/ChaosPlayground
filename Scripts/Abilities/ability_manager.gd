extends Node3D
class_name AbilityManager

@export var camera : Camera3D
@export var player : Player
@export var playerVisuals : Node3D
@export_group("Temp")
@export var hollowPurpleResource : HollowPurpleResource

var isLocked : bool = false : set = setLocked ##Set to true whenever you are currently activating an ability so that you can't use more than one ability at once

var abilities : Array[BaseAbility] ##Array of currently held abilities
@export_group("Multiplayer")
@export var currentAbilityIndex : int = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(1).timeout
	rpc("getAbility", hollowPurpleResource)
	await get_tree().create_timer(1).timeout
	rpc("getAbility", hollowPurpleResource)
	await get_tree().create_timer(1).timeout
	rpc("getAbility", hollowPurpleResource)
	await get_tree().create_timer(3).timeout
	rpc("getAbility", hollowPurpleResource)
	
	setAbilityActive(currentAbilityIndex)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _unhandled_input(event):
	var abilitiesSize : int = abilities.size()
	
	if event.is_action_pressed("changeActiveAbilityLeft") and not isLocked and player.is_multiplayer_authority():
		if currentAbilityIndex > 0:
			rpc("setAbilityActive", currentAbilityIndex - 1)
			#setAbilityActive(currentAbilityIndex - 1)
			currentAbilityIndex -= 1
		else:
			rpc("setAbilityActive", abilities.size() - 1)
			#setAbilityActive(abilities.size() - 1)
			currentAbilityIndex = abilities.size() - 1
	
	elif event.is_action_pressed("changeActiveAbilityRight") and not isLocked and player.is_multiplayer_authority():
		if currentAbilityIndex < abilities.size() - 1:
			rpc("setAbilityActive", currentAbilityIndex + 1)
			#setAbilityActive(currentAbilityIndex + 1)
			currentAbilityIndex += 1
		else:
			rpc("setAbilityActive", 0)
			#setAbilityActive(0)
			currentAbilityIndex = 0
	
	elif event.is_action_pressed("Hotbar Slot 1") and not abilities.is_empty():
		rpc("setAbilityActive", 0)
		currentAbilityIndex = 0
	elif event.is_action_pressed("Hotbar Slot 2") and abilitiesSize >= 2:
		rpc("setAbilityActive", 1)
		currentAbilityIndex = 1
	elif event.is_action_pressed("Hotbar Slot 3") and abilitiesSize >= 3:
		rpc("setAbilityActive", 2)
		currentAbilityIndex = 2
	elif event.is_action_pressed("Hotbar Slot 4") and abilitiesSize >= 4:
		rpc("setAbilityActive", 3)
		currentAbilityIndex = 3
	elif event.is_action_pressed("Hotbar Slot 5") and abilitiesSize >= 5:
		rpc("setAbilityActive", 4)
		currentAbilityIndex = 4
	elif event.is_action_pressed("Hotbar Slot 6") and abilitiesSize >= 6:
		rpc("setAbilityActive", 5)
		currentAbilityIndex = 5
	elif event.is_action_pressed("Hotbar Slot 7") and abilitiesSize >= 7:
		rpc("setAbilityActive", 6)
		currentAbilityIndex = 6
	elif event.is_action_pressed("Hotbar Slot 8") and abilitiesSize >= 8:
		rpc("setAbilityActive", 7)
		currentAbilityIndex = 7
	elif event.is_action_pressed("Hotbar Slot 9") and abilitiesSize >= 9:
		rpc("setAbilityActive", 8)
		currentAbilityIndex = 8

@rpc("any_peer", "call_local")
func setAbilityActive(index : int):
	if not abilities.is_empty():
		var currentAbility : BaseAbility = abilities[currentAbilityIndex]
		currentAbility.isSelected = false
		
		var newAbility : BaseAbility = abilities[index]
		newAbility.isSelected = true

func setLocked(status : bool):
	isLocked = status
	var ability : BaseAbility = abilities[currentAbilityIndex]
	
	if player.is_multiplayer_authority():
		ability.abilityHud.setActive(status)

@rpc("any_peer", "call_local")
func getAbility(resource : BaseAbilityResource):
	var ability : BaseAbility = resource.abilityScene.instantiate()
	ability.abilityResourceBase = resource
	
	add_child(ability, true)
	ability.config()
	abilities.append(ability)
	
	if player.is_multiplayer_authority():
		var hud : HUD = player.hud
		ability.abilityHud = hud.addAbility(ability, resource.icon)
