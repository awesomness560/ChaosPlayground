extends Node

@export var playerScene : PackedScene

#Steam variables
var steamAppId : int = 480

var steamId : int = 0
var steamUsername : String = ""
var isOnline : bool = false

var lobbyId : int = 0

# Called when the node enters the scene tree for the first time.

func _ready():
	initalizeSteam()


func initalizeSteam():
	var initialize_response: Dictionary = Steam.steamInitEx(false, steamAppId)
	print("Did Steam initialize?: %s" % initialize_response)
	
	if initialize_response['status'] > 0:
		print("Failed to initialize Steam. %s" % initialize_response)
	
	steamId = Steam.getSteamID()
	steamUsername = Steam.getPersonaName()
	isOnline = Steam.loggedOn()
	
	print("Username: " + str(steamUsername) + " | Steam ID: " + str(steamId))

func _process(delta):
	Steam.run_callbacks()
