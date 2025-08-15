extends Panel
@onready var time_ms_: Label = $"TIME(ms)"
@onready var time_s_: Label = $"TIME(s)"
@onready var time_m_: Label = $"TIME(m)"
var total_time: float = 0.0
var ms: int = 0
var s: int = 0
var m: int = 0


func _ready() -> void:
	pass

func _process(delta: float) -> void:
	total_time = Global.total_time
	m = fmod(total_time, 3600) / 60
	s = fmod(total_time, 60)
	ms = fmod(total_time, 1) * 100
	time_m_.text = "TIME    " + str(m) + "'"
	if str(s).length() < 2:
		time_s_.text= "0" + str(s) + "''"
	else:
		time_s_.text= str(s) + "''"
	time_ms_.text= str(ms)
	$"../SCORE".text = "SCORE " + str(Global.Cutscene_score)
	$"../RINGS".text = "RINGS " + str(Global.Cutscene_ring)
