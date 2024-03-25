extends RigidBody3D

@export var shapeCast : ShapeCast3D
@export var speed = 30
@export var animationPlayer : AnimationPlayer

var velocity : Vector3
var isAbleToBreak : bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	top_level = true

func config():
	velocity = linear_velocity
	animationPlayer.play("startup")
	freeze = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#if direction:
		#print(direction)
		#position += direction * speed * delta
	
	#translate(direction * speed * delta)
	
	shapeCast.force_shapecast_update()
	if shapeCast.is_colliding() and isAbleToBreak:
		for i in shapeCast.get_collision_count():
			if shapeCast.get_collider(i).has_method("destroyTile"):
				shapeCast.get_collider(i).destroyTile.rpc(shapeCast.get_collision_point(i) - shapeCast.get_collision_normal(i))


func _on_delete_timer_timeout():
	queue_free()


func _on_hollow_purple_animation_finished(anim_name):
	freeze = false
	linear_velocity = velocity
	isAbleToBreak = true
	#HACK: I am using too many get_parent(). Please don't do this
	var cam : PlayerCamera = get_parent().get_parent().get_parent()
	cam._camera_shake()
