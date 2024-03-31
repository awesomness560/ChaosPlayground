extends MultiplayerSpawner

@export var playerScene : PackedScene
# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_function = spawnPlayer
	if is_multiplayer_authority():
		spawn(1)
		multiplayer.peer_connected.connect(spawn)
		multiplayer.peer_disconnected.connect(removePlayer)

var players : Dictionary = {}

func spawnPlayer(data):
	var p = playerScene.instantiate()
	p.name = str(data)
	p.username.text = str(Steam.getPersonaName())
	players[data] = p
	return p

func removePlayer(data):
	players[data].queue_free()
	players.erase(data)
