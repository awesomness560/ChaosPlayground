extends Node3D

@export var mainMenu : PackedScene
@export var spaceBackground : PackedScene
@export var levelHouse : MultiplayerSpawner

func _ready():
	SignalBus.switchToMainMenu.connect(switchToDefault)

func switchToDefault():
	levelHouse.get_child(0).queue_free()
	var menu : Node = mainMenu.instantiate()
	add_child(menu)
