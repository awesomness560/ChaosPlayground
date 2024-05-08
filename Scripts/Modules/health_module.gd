extends Node
class_name HealthModule

signal Died

@export var maxHealth : float = 100
var healthBar : HealthBar

var dead : bool = false

@export_group("For Multiplayer (No Need to Adjust)")
@export var health : float = 100 ##Curent health of player

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_parent().ready
	
	if get_parent().is_multiplayer_authority(): #HACK: Please find a better way to do this (get_parent)
		healthBar = get_parent().get_node_or_null("Hud").healthBar
	
	health = maxHealth
	if healthBar:
		healthBar.initHealth(maxHealth)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if Input.is_key_pressed(KEY_T):
		takeDamage(10)

func takeDamage(damage):
	health -= damage
	if health <= 0:
		health = 0
		if not dead:
			Died.emit()
			dead = true
	
	if healthBar:
		healthBar.health = health

func restoreHealth():
	health = maxHealth
	if healthBar:
		healthBar.initHealth(maxHealth)
		dead = false
