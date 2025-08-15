extends HSlider

@export var Bus_name: String
@export var starting_value: int = 50
var Bus_index: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Bus_index = AudioServer.get_bus_index(Bus_name)
	# Temporarily block signals
	value_changed.disconnect(_on_value_changed)
	value = starting_value
	_on_value_changed(value)
	value_changed.connect(_on_value_changed)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_value_changed(value: float):
	AudioServer.set_bus_volume_db(Bus_index,linear_to_db(value))
