extends Node2D

var lobbyId : int = 0
var peer : SteamMultiplayerPeer = SteamMultiplayerPeer.new()
@export_file() var mainLevel : String

@onready var ms = $MultiplayerSpawner

@export var vBox : VBoxContainer
# Called when the node enters the scene tree for the first time.
func _ready():
	ms.spawn_function = spawnLevel
	peer.lobby_created.connect(onLobbyCreated)
	Steam.lobby_match_list.connect(onLobbyMatchList)
	openLobbyList()

func spawnLevel(data):
	var a = (load(data) as PackedScene).instantiate()
	return a
	

func _on_host_pressed():
	peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC)
	multiplayer.multiplayer_peer = peer
	ms.spawn(mainLevel)
	$Host.hide()
	vBox.hide()

func joinLobby(id):
	peer.connect_lobby(id)
	multiplayer.multiplayer_peer = peer
	lobbyId = id
	$Host.hide()
	vBox.hide()

func onLobbyCreated(connect, id):
	if connect:
		lobbyId = id
		Steam.setLobbyData(lobbyId, "name", str(Steam.getPersonaName() + "'s Lobby"))
		Steam.setLobbyJoinable(lobbyId, true)
		print(lobbyId)

func openLobbyList():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.requestLobbyList()

func onLobbyMatchList(lobbies):
	
	for lobby in lobbies:
		var lobby_name = Steam.getLobbyData(lobby, "name")
		var memb_count = Steam.getNumLobbyMembers(lobby)
		
		var button : Button = Button.new()
		button.text = str(lobby_name, "| Players: ", memb_count)
		button.set_size(Vector2(100, 5))
		button.connect("pressed", Callable(self, "joinLobby").bind(lobby))
		
		vBox.add_child(button)

func _on_refresh_pressed():
	if vBox.get_child_count() > 0:
		for n in vBox.get_children():
			n.queue_free()
	openLobbyList()
