extends MarginContainer
class_name AbilityHudTemplate

@export var amountToMove : int = 25 ##Amount of pixel to move vertically when ability is selected
@export var timeToMove : float = 0.3 ##Time to move when it is selected

@export var abilityTextureRect : TextureRect
var tween : Tween

var uiHints : VBoxContainer ##The containher for hints
#var icon : CompressedTexture2D
#
#var progress : float
#
#func _enter_tree():
	#abilityTextureRect.texture = icon

#func _ready():
	#await get_tree().create_timer(2).timeout
	#abilityActiveStatus(true)

func abilityActiveStatus(status : bool):
	var prevPos = position
	if tween:
		tween.kill()
	
	if status:
		uiHints.hide()
		tween = create_tween()
		tween.tween_property(abilityTextureRect, "global_position", Vector2(global_position.x, global_position.y - amountToMove), timeToMove)
	else:
		uiHints.show()
		tween = create_tween()
		tween.tween_property(abilityTextureRect, "global_position", Vector2(global_position.x, global_position.y + amountToMove), timeToMove)
		

func config(ability : BaseAbility, _icon : CompressedTexture2D, hints : VBoxContainer):
	ability.cooldownTime.connect(changeProgress)
	abilityTextureRect.texture = _icon
	uiHints = hints

func setActive(status : bool): ##Sets the shader to active on that ability
	var mat : Material = abilityTextureRect.material
	mat.set("shader_parameter/is_active", status)

func changeProgress(amount : float):
	if not amount == 0:
		var mat : Material = abilityTextureRect.material
		mat.set("shader_parameter/progress", amount)
		mat.set("shader_parameter/cooldown_bg_switch", true)
	elif amount >= 1:
		var mat : Material = abilityTextureRect.material
		mat.set("shader_parameter/progress", 0)
		mat.set("shader_parameter/cooldown_bg_switch", false)
