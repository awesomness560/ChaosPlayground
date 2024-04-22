extends Resource
class_name BaseAbilityResource

@export_group("Core Required")
@export var abilityScene : PackedScene

@export_group("Hud Related")
@export var icon : CompressedTexture2D

@export_group("Stats")
@export_range(0, 1000, 0.1, "suffix: s") var cooldown : float = 1
