extends CanvasLayer
class_name HUD

@export var abilityTemplate : PackedScene
@export var abilityContainer : HBoxContainer
@export var sessionIDButton : Button
@export var healthBar : ProgressBar
@export var pauseMenu : Control
@export var normalHUD : Control

var id : int = 0
var isPaused : bool = false

func _ready():
	id = GlobalSteam.lobbyId
	print(GlobalSteam.lobbyId)
	sessionIDButton.text = "Join Code: " + str(id) + "(Press to copy)"

func addAbility(ability : BaseAbility, icon : CompressedTexture2D) -> AbilityHudTemplate:
	var template : AbilityHudTemplate = abilityTemplate.instantiate()
	template.config(ability, icon)
	abilityContainer.add_child(template)
	abilityContainer.move_child(template, abilityContainer.get_child_count() - 2)
	
	return template

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		if isPaused:
			normalHUD.show()
			pauseMenu.hide()
			isPaused = false
			
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			normalHUD.hide()
			pauseMenu.show()
			isPaused = true
			
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			
		get_parent().isPaused = isPaused

#region Session ID Button Code
func setID(id : int):
	var text : String = "Join Code: " + str(id) + " (Press to copy)"
	sessionIDButton.text = text


func _on_copy_session_id_pressed():
	DisplayServer.clipboard_set(str(id))
	var text : String = "Join Code: " + str(id) + " (Copied!)"
	sessionIDButton.text = text
	
	await get_tree().create_timer(2).timeout
	
	text = "Join Code: " + str(id) + " (Press to copy)"
	sessionIDButton.text = text

#endregion


func _on_resume_button_pressed():
	normalHUD.show()
	pauseMenu.hide()
	isPaused = false
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_parent().isPaused = isPaused


func _on_disconnect_pressed():
	MultiplayerManager.disconnectPlayer()
