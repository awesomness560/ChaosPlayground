extends Camera3D
class_name SpawnCamera


var player : Player
var shouldBeCurrent : bool = false ##What the value should be (in case it is not)

func _enter_tree():
	#get_parent().spawnCamera = self
	#current = false
	pass

func _ready():
	Lobby.player_connected.connect(playerConnect) #For a bug

#func _process(delta):
	#print("On peer: "+ str(multiplayer.get_unique_id()) + "Bool:" + str(current))

func _input(event):
	if Input.is_action_just_pressed("spawn") and current:
		var spawnPos : Vector3 = get_selection(event.position)
		if not spawnPos == Vector3.ZERO and player:
			spawnPos.y += 10
			player.rpc("spawn", spawnPos)
			#player.spawn(spawnPos)

func get_selection(mouse : Vector2) -> Vector3: ##Gets the position of the mouse where it clicked
	var worldspace = get_world_3d().direct_space_state
	var start = project_ray_origin(mouse)
	var end = project_position(mouse, 10000)
	var result = worldspace.intersect_ray(PhysicsRayQueryParameters3D.create(start, end))
	if result:
		return result["position"]
	else:
		return Vector3.ZERO

func playerConnect(id, playerData): #HACK: This is a bandaid fix for a problem that happens whenever a new player connects
	if shouldBeCurrent:
		current = true

func setCurrent(_player : Player, status : bool):##Changes whether we can view through this camera or not
	current = status
	shouldBeCurrent = status
	if current == true:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		player = _player 
	else:
		player = null
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
