extends Button
class_name ButtonMenu #MenuButton was taken

@export var menuToSwitch : Control ##The menu to switch to when this button is clicked
@export var hoverScale : float = 1.5 ##The scale the button should be when hovered on

@export_group("Animations")
@export var animationName : String ##The name of the animation you want to play when the button is clicked (optional)
@export var animationPlayer : AnimationPlayer ##The animation player that houses that animation

var tween : Tween

func _ready():
	initalize()
	self.pressed.connect(onPressed)

func initalize():
	self.mouse_entered.connect(onHover)
	self.mouse_exited.connect(offHover)
	pivot_offset = Vector2(size.x / 2, size.y / 2)

func onPressed(): ##Switch menu
	var parentMenu : Menu = get_parent()
	parentMenu.switchMenu(menuToSwitch)
	
	if animationPlayer:
		animationPlayer.play_backwards(animationName)

func onHover():
	tweenState(true)

func offHover():
	tweenState(false)

func tweenState(state : bool):
	if tween:
		tween.kill()
	
	tween = create_tween()
	if state:
		tween.tween_property(self, "scale", Vector2(hoverScale, hoverScale), 0.2)
	else:
		tween.tween_property(self, "scale", Vector2(1, 1), 0.2)
