extends Control
class_name Menu
#TODO: Add video settings for the world environment
var lastMenu : Control
var useEsc : bool = true ##Turn this off if you don't want to use ESC to move back a menu

@export_group("Animations")
@export var animation : String
@export var animationPlayer : AnimationPlayer

func switchMenu(menu : Control): ##Switches to a new menu
	hide()
	menu.show()
	
	if menu is Menu: #If we go to another menu, then we say that we 
		menu.lastMenu = self
	else:
		printerr("The menu you are switching to is not of the Menu class")
		#print("[color=yellow] The menu you are switching to is not of the Menu class")

func goBack(): ##Goes back to the previous menu
	if lastMenu:
		hide()
		lastMenu.show()
		lastMenu = null
		
		if animationPlayer:
			animationPlayer.play(animation)

func _unhandled_input(event):
	if event.is_action_pressed("back_ui"):
		goBack()


func _on_back_button_pressed():
	goBack()
