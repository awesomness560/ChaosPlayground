extends Node3D

@export var pulseIntensity : int = 80
@export var mesh : MeshInstance3D
var mat : ShaderMaterial
var previousPulse

var tween : Tween

var spectrum : AudioEffectSpectrumAnalyzerInstance = AudioServer.get_bus_effect_instance(1, 0)

const VU_COUNT = 5
const HEIGHT = 60
const FREQ_MAX = 11050.0
 
const MIN_DB = 60

var height : float = 0
var pulsing : bool = false
var lastPulse : bool = false

func _ready():
	mat = mesh.material_override
	#mat.set_shader_parameter("shader_parameter/Color_Intensity")
	previousPulse = mat.get_shader_parameter("shader_parameter/Color_Intensity")

func _process(delta):
	var prev_hz = 0
	var counter : int = 0
	for i in range(1,VU_COUNT+1):
		var hz = i * FREQ_MAX / VU_COUNT;
		var f = spectrum.get_magnitude_for_frequency_range(prev_hz,hz)
		var energy = clamp((MIN_DB + linear_to_db(f.length()))/MIN_DB,0,1)
		height = energy * HEIGHT
		#print(height)
		if height >= 1:
			counter += 1
 
		prev_hz = hz
	
	if counter >= 3:
		#print("pulse")
		pulsing = true
		#pulse = false
	else:
		pulsing = false
	counter = 0
	
	if lastPulse != pulsing and pulsing == true:
		#print(tween)
		#print(mat)
		#mat.set_shader_parameter("Color_Intensity", pulseIntensity)
		if tween:
			if not tween.is_running():
				makeTween()
		else:
			makeTween()
		#print("pulse")
	
	lastPulse = pulsing
	
	#var magnitude = spectrum.get_magnitude_for_frequency_range(0, 200)
	#if magnitude.x >= 0.1:
		#print("pulse")

func makeTween():
	#tween = create_tween()
	#tween.tween_method(setShaderValue, 20, pulseIntensity, 0.1)
	##tween.tween_property(mat, "Color_Intensity", pulseIntensity, 0.1)
	#tween.play()
	#tween.finished.connect(backToDefault)
	pass

func backToDefault():
	tween = create_tween()
	tween.tween_method(setShaderValue, pulseIntensity, 20, 0.1)
	tween.play()
	tween.finished.connect(killTween)

func killTween():
	tween.kill()

func setShaderValue(value : float):
	print(value)
	mat.set_shader_parameter("Color_Intensity", value)
