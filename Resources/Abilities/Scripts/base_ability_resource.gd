extends Resource
class_name BaseAbilityResource

@export_group("Core Required")
@export var abilityScene : PackedScene ##Scene that contains the actual ability

@export_group("Hud Related")
@export var icon : CompressedTexture2D ##Icon for the ability in the hotbar
@export var inputDict : Dictionary = {"launchAbility" : "to launch ability(Replace this text)"} ##Dictionary for the inputs. The keys are the names of the input and values are what is displayed after the "press" prompt

@export_group("Stats")
@export_range(0, 1000, 0.1, "suffix: s") var cooldown : float = 1 ##Cooldown time
