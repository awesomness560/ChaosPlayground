extends ButtonMenu

var peer : SteamMultiplayerPeer = SteamMultiplayerPeer.new()

func _ready():
	initalize()
	var root : Node = get_tree().current_scene
	pressed.connect(root.get_node("MainMenu").host)
