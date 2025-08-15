extends Control
@onready var score: Label = $SCORE
@onready var rings: Label = $RINGS


func _ready() -> void:
	pass

func _process(delta: float) -> void:
	score.text = "SCORE    " + str(Global.Score)
	rings.text = "RINGS    " + str(Global.Rings)
	
