# Based on "Audio Spectrum Demo"
# https://godotengine.org/asset-library/asset/528

extends Node3D

var spectrum
var bars = [] # Array to store our audio bars
const VU_COUNT = 16 # Total number of bars
const BAR_WIDTH = 0.5 # For code legibility; the exact width of our bar mesh
const FREQ_MAX = 4096 # i.e. Cutoff
const MIN_DB = 60 # i.e. Sensitivity
const HEIGHT = 10 # Max Y scale of bars
const GAP = 0.1 # Space between each bar
var print_hz_ranges = true

# Called when the node enters the scene tree for the first time.
func _ready():
	# Get the SpectrumAnalyzer effect from the Master bus
	spectrum = AudioServer.get_bus_effect_instance(0,0)

	for i in range(VU_COUNT):
		# Load and instantiate a bar
		var bar_instance = load("res://Meshes/bar.blend").instantiate()
		add_child(bar_instance)

		# Position the bar relative to the others
		bar_instance.position.x = i * (BAR_WIDTH + GAP)

		# Add the bar to our bars array so we can iterate over it in _process()
		bars.append(bar_instance)

		# Dynamically adjust the camera to focus on the bars
		get_viewport().get_camera_3d().position.x = (VU_COUNT - 1) * (BAR_WIDTH + GAP) / 2
		get_viewport().get_camera_3d().position.y = VU_COUNT / 3.2
		get_viewport().get_camera_3d().position.z = VU_COUNT / 1.6

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var prev_hz = 0
	for i in range(1, VU_COUNT + 1):
		var hz = i * FREQ_MAX / VU_COUNT # Get Hz range of the current bar
		
		if(print_hz_ranges):
			print("Bar ", i, ": ", prev_hz, " - ", hz, "Hz")
		
		var magnitude = spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
		var energy = clamp((MIN_DB + linear_to_db(magnitude)) / MIN_DB, 0, 1)
		
		# Set bar height, using linear interpolation to smooth the animation
		var prev_height = bars[i - 1].scale.y
		var height : float = energy * HEIGHT
		bars[i - 1].scale.y = lerp(prev_height, height, 0.33)
		
		prev_hz = hz
	print_hz_ranges = false # Ensures that the Hz ranges print only once
