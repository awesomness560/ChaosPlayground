extends CanvasLayer

@export var playerScene : PackedScene
@export_group("References")
@export var menu : PanelContainer
@export var addressEntry : LineEdit
@export var usernameEntry : LineEdit
@export var hostButton : Button
@export var joinButton : Button

@onready var sceneManager : SceneManager = $/root/SceneManager
const PORT : int = 7000
#var enet_peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()

func _ready():
	#Menu signals connections
	hostButton.pressed.connect(on_host_button_pressed)
	joinButton.pressed.connect(on_join_button_pressed)
	
	#Lobby signals connections
	Lobby.player_connected.connect(onPlayerConnected)
	Lobby.player_disconnected.connect(removePlayer)

func on_host_button_pressed():
	menu.hide()
	
	Lobby.player_info[usernameEntry.text] = null #Set username
	Lobby.create_game()

func on_join_button_pressed():
	menu.hide()
	
	Lobby.player_info[usernameEntry.text] = null #Set username
	Lobby.join_game(addressEntry.text)

func onPlayerConnected(id : int, playerInfo : Dictionary):
	#addPlayer(id, playerInfo.keys()[0])
	MultiplayerManager.connectPlayer(id)

func addPlayer(peer_id = 1, username : String = "NoName"):
	var player : Player = playerScene.instantiate()
	player.name = str(peer_id)
	player.username = username
	add_child(player)
	player.global_position.y += 80

func removePlayer(id):
	MultiplayerManager.removePlayer(id)

#Previous Code for Reference
#func _on_host_button_pressed():
	#menu.hide()
	#
	#enet_peer.create_server(PORT)
	#multiplayer.multiplayer_peer = enet_peer
	#multiplayer.peer_connected.connect(addPlayer)
	#multiplayer.peer_disconnected.connect(removePlayer)
	#
	#addPlayer()
#
#func _on_join_button_pressed():
	#menu.hide()
	#
	#var error = enet_peer.create_client(addressEntry.text, PORT)
	#if error:
		#return error
	#multiplayer.multiplayer_peer = enet_peer
#
#func addPlayer(peer_id = 1):
	#var player : CharacterBody3D = playerScene.instantiate()
	#player.name = str(peer_id)
	#add_child(player)
	#player.global_position = spawnPoint.global_position
	#players.append(player)
#
#func removePlayer(peer_id = 1):
	#var player = get_node_or_null(str(peer_id))
	#if player:
		#players.erase(player)
		#player.queue_free()
#
###@deprecated
#func upnpSetup():
	#var upnp = UPNP.new()
	#
	#var discover_result = upnp.discover()
	#assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		#"UPNP Discover Failed! Error %s" % discover_result)
	#
	##print(upnp.get_gateway())
	##
	##assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		##"UPNP Invalid Gateway!")
	#
	#var map_result = upnp.add_port_mapping(PORT)
	#assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		#"UPNP Port Mapping Failed! Error %s" % map_result)
	#
	#print("Success! Join Address: %s" % upnp.query_external_address())






