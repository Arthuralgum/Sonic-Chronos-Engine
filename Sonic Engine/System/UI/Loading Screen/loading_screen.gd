extends Control

#Loading System var
@export_file("*.tscn") var next_scene_path: String
var progress: Array
var update: float = 0.0


#Assets stuff var
@onready var loading_progress_bar: TextureProgressBar = $MarginContainer2/LoadingProgressBar

@onready var blue_arrow: TextureRect = $"Blue Arrow"
@onready var yellow_arrow: TextureRect = $"Yellow Arrow"
@onready var red_arrow: TextureRect = $"Red Arrow"
@onready var label: Label = $MarginContainer/Label
var red_initial_position: Vector2
var yellow_initial_position: Vector2
var blue_initial_position: Vector2

@onready var end_mark_blue: Marker2D = $End_Position_Blue
@onready var end_mark_yellow: Marker2D = $End_Position_Yellow
@onready var end_mark_red: Marker2D = $End_Position_Red
var blue_end_position: Vector2
var yellow_end_position: Vector2
var red_end_position: Vector2

var total_time: float = 1.25
var time_elapsed: float = 0.0

var red_delay: float = 0.5
var yellow_delay: float = 0.3
var blue_delay: float = 0.0


func _ready() -> void:
	ResourceLoader.load_threaded_request(next_scene_path)
	red_initial_position = red_arrow.global_position
	yellow_initial_position = yellow_arrow.global_position
	blue_initial_position = blue_arrow.global_position
	blue_end_position = end_mark_blue.global_position + Vector2(-40.0,6.0)
	yellow_end_position = end_mark_yellow.global_position + Vector2(-40.0,6.0)
	red_end_position = end_mark_red.global_position + Vector2(-40.0,6.0)
func _process(delta: float) -> void:
	print(progress)
	ResourceLoader.load_threaded_get_status(next_scene_path, progress)
	if progress[0] > update:
		update = progress[0]
		
	if loading_progress_bar.value < update * 200:
		if loading_progress_bar.value < 80.0:
			loading_progress_bar.value = lerp(loading_progress_bar.value, update * 100, 0.2)
		else:
			loading_progress_bar.value = lerp(loading_progress_bar.value, update * 100, 0.5)
	if ResourceLoader.load_threaded_get_status(next_scene_path) == ResourceLoader.THREAD_LOAD_LOADED:
		var new_scene: PackedScene = ResourceLoader.load_threaded_get(next_scene_path)
		await get_tree().create_timer(0.7).timeout
		print("LOADED")
		get_tree().change_scene_to_packed(new_scene)
	time_elapsed += delta

	# Total cycle duration (after green arrow finishes)
	var cycle_duration = total_time + red_delay
	if time_elapsed > cycle_duration:
		time_elapsed = 0.0  # restart the loop

	# Update each arrow individually
	update_arrow(red_arrow, time_elapsed - red_delay, red_initial_position, red_end_position)
	update_arrow(yellow_arrow, time_elapsed - yellow_delay, yellow_initial_position, yellow_end_position)
	update_arrow(blue_arrow, time_elapsed - blue_delay, blue_initial_position, blue_end_position)
	
func update_arrow(arrow: TextureRect, arrow_time: float, initial_position: Vector2, end_position: Vector2) -> void:
	if arrow_time < 0.0:
		arrow.global_position = initial_position
	elif arrow_time > total_time:
		arrow.global_position.x = end_position.x
	else:
		var t = arrow_time / total_time
		var eased_t = ease(t, -2.0)  # Smooth ease-in
		arrow.global_position.x = lerp(initial_position.x, end_position.x, eased_t)
