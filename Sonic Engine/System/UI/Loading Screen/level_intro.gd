extends Control
var red_polygon_entered: bool = false
var sonic_logo: bool = false
var shadow_logo: bool = false
@export var stage_number: String
@export var stage_title_first_line: String
@export var stage_title_second_line: String
@export var intro_time: float = 1.0
var intro_finished: bool = false
func _ready() -> void:
	$"Level Title/Label".text = stage_title_first_line + "\n" + stage_title_second_line

	$"Stage Number/Label".text = "Stage "+ stage_number + ":"

	if Global.playable_char_path == "res://Player/Characters/Shadow/Shadow.tscn":
		$"Sonic Logo".hide()
		shadow_logo = true
	else:
		$"Shadow Logo".hide()
		sonic_logo = true
	$"Red Polygon Anim".play("enter")
	$"Sonic Logo Anim".play("enter")
	$Labels.play("Enter")
	await $"Red Polygon Anim".animation_finished
	red_polygon_entered = true
	$Intro_Duration.wait_time = intro_time
	$Intro_Duration.start()
func _process(delta: float) -> void:
	if red_polygon_entered:
		$"Red Polygon Anim".play("loop")

func _on_intro_duration_timeout() -> void:
	if shadow_logo:
		$"AfterImage/Shadow Logo(Afterimage)".show()
	else:
		$"AfterImage/Sonic Logo(Afterimage)".show()
	$"Sonic Logo Anim".play("afterimage")
	await $"Sonic Logo Anim".animation_finished
	$"Sonic Logo Anim".play("fade_out")
	intro_finished = true
	$Intro_Duration.stop()
