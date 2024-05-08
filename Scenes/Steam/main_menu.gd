extends Node

var peer : SteamMultiplayerPeer = SteamMultiplayerPeer.new()
@export var levelHouse : MultiplayerSpawner
@export var mainLevel : PackedScene
@export var portal : Node3D
@export_group("Lobbies")
@export var lobbyVBox : VBoxContainer
@export var lobbyButtonTemplate : PackedScene
@export var lobbyLineEdit : LineEdit

func _ready():
	levelHouse.spawn_function = spawnLevel
	
	peer.lobby_created.connect(onLobbyCreated)
	Steam.lobby_match_list.connect(onLobbyMatchList)
	peer.lobby_joined.connect(_on_lobby_joined)
	openLobbyList()

func spawnLevel(scene : PackedScene):
	var level = scene.instantiate()
	return level

func host():
	peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC)
	multiplayer.multiplayer_peer = peer
	levelHouse.spawn(mainLevel)

func join(id):
	print("attempted to join")
	peer.connect_lobby(id)
	multiplayer.multiplayer_peer = peer
	GlobalSteam.lobbyId = id

func onLobbyCreated(connect, id):
	if connect:
		GlobalSteam.lobbyId = id
		var lobbyId = GlobalSteam.lobbyId
		Steam.setLobbyData(lobbyId, "name", str(Steam.getPersonaName() + "'s Lobby"))
		Steam.setLobbyJoinable(lobbyId, true)
		print(lobbyId)
		
		#Get rid of the main menu
		MultiplayerManager.startGame()
		queue_free()

func onLobbyMatchList(lobbies):
	for lobby in lobbies:
		var lobby_name = Steam.getLobbyData(lobby, "name")
		var memb_count = Steam.getNumLobbyMembers(lobby)
		
		var button : Button = lobbyButtonTemplate.instantiate()
		button.text = str(lobby_name, "| Players: ", memb_count)
		button.connect("pressed", Callable(self, "join").bind(lobby))
		
		lobbyVBox.add_child(button)

func openLobbyList():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.requestLobbyList()

func _on_lobby_joined(this_lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	print("joined")

#Signal Functions
func _on_refresh_pressed():
	if lobbyVBox.get_child_count() > 0:
		for n in lobbyVBox.get_children():
			n.queue_free()
	openLobbyList()


func _on_join_with_code_pressed():
	var lobbyCode = lobbyLineEdit.text.to_int()
	join(lobbyCode)
