extends GridMap


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

@rpc("any_peer", "call_local")
func destroyTile(collisionPoint):
	var mapCoordinate = local_to_map(collisionPoint)
	set_cell_item(mapCoordinate, -1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
