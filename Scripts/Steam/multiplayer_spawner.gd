extends MultiplayerSpawner

@export var playerScene : PackedScene
# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_function = spawnPlayer

var players : Dictionary = {}

func startGame():
	if is_multiplayer_authority():
		spawn(1)
		multiplayer.peer_connected.connect(spawn)
		multiplayer.peer_disconnected.connect(removePlayer)

func spawnPlayer(data):
	#var p = playerScene.instantiate()
	#p.name = str(data)
	##p.username.text = str(Steam.getPersonaName())
	#players[data] = p
	return MultiplayerManager.addPlayer(data)

func removePlayer(data):
	#players[data].queue_free()
	MultiplayerManager.removePlayer(data)
	players.erase(data)
