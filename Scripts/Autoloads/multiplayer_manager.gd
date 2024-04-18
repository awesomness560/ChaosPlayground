extends Node

#enum connectionType{SERVER, CLIENT}
@export var player : PackedScene

var mainCharacterSpawned : bool = false

func _ready():
	pass

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
	player.global_position.y += 80
	
	add_child(player)
	player.add_child(voxelViewer)
	
	return player

func removePlayer(peer_id):
	var player = get_node(str(peer_id))
	player.queue_free()