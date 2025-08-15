extends Control
class_name Character
var characters: Array = []
@onready var Slot_1 := $"VBoxContainer/HBoxContainer/Character 1"
@onready var Slot_2 := $"VBoxContainer/HBoxContainer/Character 2"
@onready var Slot_3 := $"VBoxContainer/HBoxContainer/Character 3"
func _ready() -> void:
	$Fade_effect.show()
	$Fade_effect/AnimationPlayer.play("fade_out")
	characters = [Slot_1,Slot_2,Slot_3]
	Global.playable_char_path = characters[1].character_path
	characters[1].char_slot_animation.play("Animation")
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_left"):
		$"VBoxContainer/HBoxContainer/Character 2/Menu Arrow".stop()
		$"VBoxContainer/HBoxContainer/Character 2/Menu Arrow".play()
		$"VBoxContainer/HBoxContainer/Character 2/Left Arrow Up".color = Color(0.35, 0.739, 0.76)
		$"VBoxContainer/HBoxContainer/Character 2/Left Arrow Down".color = Color(0.352, 0.589, 0.69)
		var last = characters.pop_back()
		characters.insert(0, last)
		
		var pos1 = characters[0].char_slot_animation.global_position
		var pos2 = characters[1].char_slot_animation.global_position
		var pos3 = characters[2].char_slot_animation.global_position
		
		characters[0].char_slot_animation.global_position = pos2
		characters[1].char_slot_animation.global_position = pos3
		characters[2].char_slot_animation.global_position = pos1
		
		Global.playable_char_path = characters[1].character_path
		
		characters[1].char_slot_animation.play("Animation")
		characters[0].char_slot_animation.stop()
		characters[2].char_slot_animation.stop()
		characters[1].char_slot_animation.modulate.a = 1
		characters[0].char_slot_animation.modulate.a = 0.5
		characters[2].char_slot_animation.modulate.a = 0.5
		
		await get_tree().create_timer(0.3).timeout
		
		$"VBoxContainer/HBoxContainer/Character 2/Left Arrow Up".color = Color(0.84, 0.84, 0.84)
		$"VBoxContainer/HBoxContainer/Character 2/Left Arrow Down".color = Color(0.587, 0.604, 0.66)
		
		if characters[1] == $"VBoxContainer/HBoxContainer/Character 1" or characters[1] == $"VBoxContainer/HBoxContainer/Character 3":
			await characters[1].char_slot_animation.animation_finished
			characters[1].char_slot_animation.play("Loop")
			
	if Input.is_action_just_pressed("ui_right"):
		$"VBoxContainer/HBoxContainer/Character 2/Menu Arrow".stop()
		$"VBoxContainer/HBoxContainer/Character 2/Menu Arrow".play()
		$"VBoxContainer/HBoxContainer/Character 2/Right Arrow Up".color = Color(0.35, 0.739, 0.76)
		$"VBoxContainer/HBoxContainer/Character 2/Right Arrow Down".color = Color(0.352, 0.589, 0.69)
		
		var first = characters.pop_front()
		characters.append(first)
		
		var pos1 = characters[0].char_slot_animation.global_position
		var pos2 = characters[1].char_slot_animation.global_position
		var pos3 = characters[2].char_slot_animation.global_position
		
		characters[0].char_slot_animation.global_position = pos3
		characters[1].char_slot_animation.global_position = pos1
		characters[2].char_slot_animation.global_position = pos2
		
		Global.playable_char_path = characters[1].character_path
		
		characters[1].char_slot_animation.play("Animation")
		characters[0].char_slot_animation.stop()
		characters[2].char_slot_animation.stop()
		characters[1].char_slot_animation.modulate.a = 1
		characters[0].char_slot_animation.modulate.a = 0.5
		characters[2].char_slot_animation.modulate.a = 0.5
		
		await get_tree().create_timer(0.3).timeout
		
		$"VBoxContainer/HBoxContainer/Character 2/Right Arrow Up".color = Color(0.84, 0.84, 0.84)
		$"VBoxContainer/HBoxContainer/Character 2/Right Arrow Down".color = Color(0.587, 0.604, 0.66)
		
		if characters[1] == $"VBoxContainer/HBoxContainer/Character 1" or characters[1] == $"VBoxContainer/HBoxContainer/Character 3":
			await characters[1].char_slot_animation.animation_finished
			characters[1].char_slot_animation.play("Loop")
	
	if Input.is_action_just_pressed("ui_accept"):
		$"VBoxContainer/HBoxContainer/Character 2/Right Arrow Up".z_index = 0
		$"VBoxContainer/HBoxContainer/Character 2/Left Arrow Up".z_index = 0
		$"VBoxContainer/HBoxContainer/Character 2/Right Arrow Down".z_index = 0
		$"VBoxContainer/HBoxContainer/Character 2/Left Arrow Down".z_index = 0
		$"VBoxContainer/MarginContainer2/Menu Select".play()
		$Fade_effect.show()
		$Fade_effect/Fade_timer.start()
		$Fade_effect/AnimationPlayer.play("fade_in")


func _on_fade_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://System/UI/Level Selection Screen/Level selection screen.tscn")
