extends Node3D

@export var animationPlayer : AnimationPlayer
var animationName : String = "rock_gate|rock_gate|gate_crush"

func _ready():
	animationPlayer.play(animationName, -1, 1, true)
	animationPlayer.stop(true)
