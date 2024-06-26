extends MultiplayerSpawner

#enum connectionType{SERVER, CLIENT}
@export var player : PackedScene
@export var mapCamera : PackedScene

var players : int = 0
var mainCharacterSpawned : bool = false

func _ready():
	spawn_function = connectPlayer

func startGame():
	if is_multiplayer_authority():
		spawn(1)
		multiplayer.peer_connected.connect(spawn)
		multiplayer.peer_disconnected.connect(removePlayer)

func connectPlayer(peer_id):
	var voxelViewer : VoxelViewer = VoxelViewer.new()
	
	if multiplayer.is_server():
		voxelViewer.set_network_peer_id(int(peer_id))
		if mainCharacterSpawned: #If we are not the server player. Aka if we are not a client
			voxelViewer.requires_data_block_notifications = true
			voxelViewer.requires_visuals = false
		else:
			mainCharacterSpawned = true
	
	var player := player.instantiate()
	player.name = str(peer_id)
	#player.global_position = Vector3(200, 200, 200)
	
	add_child(player)
	player.add_child(voxelViewer)
	players += 1
	
	return player

func removePlayer(peer_id):
	var player = get_node(str(peer_id))
	player.queue_free()

func disconnectPlayer():
	multiplayer.multiplayer_peer = null
	for child in get_children():
		child.queue_free()
	
	SignalBus.switchToMainMenu.emit()
