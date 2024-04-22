extends CanvasLayer
class_name HUD

@export var abilityTemplate : PackedScene
@export var abilityContainer : HBoxContainer

func addAbility(ability : BaseAbility, icon : CompressedTexture2D) -> AbilityHudTemplate:
	var template : AbilityHudTemplate = abilityTemplate.instantiate()
	template.config(ability, icon)
	abilityContainer.add_child(template)
	abilityContainer.move_child(template, abilityContainer.get_child_count() - 2)
	
	return template
