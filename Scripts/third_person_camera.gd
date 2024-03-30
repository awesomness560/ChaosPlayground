extends SpringArm3D

@export var mouseSensitivity : float = 0.05
var player : Node3D

func _ready():
	top_level = true
	player = get_parent()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.x -= event.relative.y * mouseSensitivity
		rotation_degrees.x = clamp(rotation_degrees.x, -90, 30)
		
		rotation_degrees.y -= event.relative.x * mouseSensitivity
		rotation_degrees.y = wrapf(rotation_degrees.y, 0, 360)
