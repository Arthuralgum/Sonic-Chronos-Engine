extends RemoteTransform2D
@onready var sonicNode = $"../../../../Player"
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if Global.CanRail:
		remote_path = sonicNode.get_path()
