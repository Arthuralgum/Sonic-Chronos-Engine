extends HSlider

@export var Bus_name: String
var Bus_index: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Bus_index = AudioServer.get_bus_index(Bus_name)
	value_changed.connect(_on_value_changed)
	
	value = db_to_linear(AudioServer.get_bus_volume_db(Bus_index))
	value = 50

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_value_changed(value: float):
	AudioServer.set_bus_volume_db(Bus_index,linear_to_db(value))
