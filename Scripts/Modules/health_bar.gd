extends ProgressBar
class_name HealthBar

@export var timeToTween : float = 0.2 ##The time it takes for the progress bar to reach the real value
@export var timer : Timer
@export var damageBar : ProgressBar

var health = 0 : set = setHealth

var damageBarTween : Tween
var healthBarTween : Tween

func _ready():
	timer.timeout.connect(onTimerTimeout)

func setHealth(newHealth):
	var prevHealth = health
	health = min(max_value, newHealth)
	tweenHealth(health)
	
	if health < prevHealth:
		timer.start()
	else:
		tweenDamage(health)

func initHealth(_health): ##Call when using the health bar so that the health bar can be set up correctly
	health = _health
	max_value = health
	value = health
	
	damageBar.max_value = health
	damageBar.value = health

func onTimerTimeout():
	tweenDamage(health)

func tweenHealth(_health):
	if healthBarTween:
		healthBarTween.kill()
		
	healthBarTween = create_tween()
	healthBarTween.tween_property(self, "value", _health, timeToTween)

func tweenDamage(_health):
	if damageBarTween:
		damageBarTween.kill()
	
	damageBarTween = create_tween()
	damageBarTween.tween_property(damageBar, "value", _health, timeToTween)
