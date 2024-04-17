extends Camera3D
class_name PlayerCamera

@export var period = 0.3
@export var magnitude = 0.4

var voxelTool : VoxelTool

func _ready():
	var terrain : VoxelTerrain = get_tree().get_first_node_in_group("terrain")
	voxelTool = terrain.get_voxel_tool()
	voxelTool.channel = VoxelBuffer.CHANNEL_TYPE
	voxelTool.value = 0
	

func _camera_shake():
	var initial_transform = self.transform 
	var elapsed_time = 0.0

	while elapsed_time < period:
		var offset = Vector3(
			randf_range(-magnitude, magnitude),
			randf_range(-magnitude, magnitude),
			0.0
		)

		self.transform.origin = initial_transform.origin + offset
		elapsed_time += get_process_delta_time()
		await get_tree().process_frame

	self.transform = initial_transform

func _unhandled_input(event):
	if event.is_action_pressed("del"):
		var forward := -get_transform().basis.z.normalized()
		var hit := voxelTool.raycast(global_position, forward, 100)
		voxelTool.do_point(hit.position)
