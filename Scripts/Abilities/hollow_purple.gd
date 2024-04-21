extends BaseAbility
class_name HollowPurpleProjectile

signal initalAnimationFinished
@export var speed = 30
@export var damage = 20

@export_group("References")
@export var shapeCast : ShapeCast3D
@export var animationPlayer : AnimationPlayer
@export var damageModule : DamageModule
var abilityManager : AbilityManager

var velocity : Vector3
var isAbleToBreak : bool = false
var voxelTool : VoxelTool
# Called when the node enters the scene tree for the first time.
func _ready():
	#top_level = true
	pass

func config():
	var terrain : VoxelTerrain = get_tree().get_first_node_in_group("terrain")
	voxelTool = terrain.get_voxel_tool()
	voxelTool.channel = VoxelBuffer.CHANNEL_TYPE
	voxelTool.value = 0
	
	velocity = self.linear_velocity
	animationPlayer.play("startup")
	self.freeze = true
	abilityManager = get_parent().get_parent() #HACK: get_parent is not the nicest way of doing this
	abilityManager.player.controlMode = abilityManager.player.ControllerType.THIRD_PERSON

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#if direction:
		#print(direction)
		#position += direction * speed * delta
	
	#translate(direction * speed * delta)
	#voxelTool.do_sphere(global_position, 5)
	#shapeCast.force_shapecast_update()
	if shapeCast.is_colliding() and isAbleToBreak:
		voxelTool.do_sphere(global_position, 5)
		for i in shapeCast.get_collision_count():
			damageModule.damage(shapeCast.get_collider(i), damage)
		#voxelTool.do_sphere(position, 2000)
		#voxelTool.do_point(shapeCast.get_collision_point(0))
		#for i in shapeCast.get_collision_count():
			#voxelTool.set_voxel(shapeCast.get_collision_point(i), 0)
		#print(voxelTool.get_voxel(shapeCast.get_collision_point(0)))
		#var vox := voxelTool.get_voxel(shapeCast.get_collision_point(0))
		#vox = 0
		#voxelTool.set_voxel(shapeCast.get_collision_point(0), 0)
		
		#for i in shapeCast.get_collision_count():
			#if shapeCast.get_collider(i).has_method("destroyTile"):
				#shapeCast.get_collider(i).destroyTile.rpc(shapeCast.get_collision_point(i) - shapeCast.get_collision_normal(i))


func _on_delete_timer_timeout():
	queue_free()


func _on_hollow_purple_animation_finished(anim_name):
	initalAnimationFinished.emit()
	top_level = true
	self.freeze = false
	self.linear_velocity = velocity
	isAbleToBreak = true
	#HACK: I am using too many get_parent(). Please don't do this
	var cam : PlayerCamera = get_parent().get_parent().get_parent()
	cam._camera_shake()
	
	abilityManager.player.controlMode = abilityManager.player.ControllerType.FIRST_PERSON
	
	
	
	
	
	
	
	
