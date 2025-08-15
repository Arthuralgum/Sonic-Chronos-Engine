extends Control
class_name Level
var levels: Array = []
var positions: Array = []
var label_positions: Array = []
var selection_lock: bool = false
var middle_index: int

@onready var slot_0_marker: Marker2D = $Slot0_Marker
@onready var slot_1_marker: Marker2D = $Slot1_Marker
@onready var slot_2_marker: Marker2D = $Slot2_Marker
@onready var slot_3_marker: Marker2D = $Slot3_Marker
@onready var slot_4_marker: Marker2D = $Slot4_Marker

@onready var slot_0_marker_label: Marker2D = $Slot0_Marker_Label
@onready var slot_1_marker_label: Marker2D = $Slot1_Marker_Label
@onready var slot_2_marker_label: Marker2D = $Slot2_Marker_Label
@onready var slot_3_marker_label: Marker2D = $Slot3_Marker_Label
@onready var slot_4_marker_label: Marker2D = $Slot4_Marker_Label

var level_targets: Array = [
		{ "sprite_pos": slot_0_marker, "label_pos": slot_0_marker_label },
		{ "sprite_pos": slot_1_marker, "label_pos": slot_1_marker_label },
		{ "sprite_pos": slot_2_marker, "label_pos": slot_2_marker_label },
		{ "sprite_pos": slot_3_marker, "label_pos": slot_3_marker_label },
		{ "sprite_pos": slot_4_marker, "label_pos": slot_4_marker_label },
	]

#Arrow assets
@onready var right_arrow_up: Polygon2D = %"Right Arrow Up"
@onready var right_arrow_down: Polygon2D = %"Right Arrow Down"
@onready var left_arrow_up: Polygon2D = %"Left Arrow Up"
@onready var left_arrow_down: Polygon2D = %"Left Arrow Down"

func _ready() -> void:
	level_targets = [
		{ "sprite_pos": slot_1_marker.global_position, "label_pos": slot_1_marker_label.global_position },
		{ "sprite_pos": slot_2_marker.global_position, "label_pos": slot_2_marker_label.global_position },
		{ "sprite_pos": slot_3_marker.global_position, "label_pos": slot_3_marker_label.global_position },
		{ "sprite_pos": slot_4_marker.global_position, "label_pos": slot_4_marker_label.global_position },
		{ "sprite_pos": slot_0_marker.global_position, "label_pos": slot_0_marker_label.global_position },
	]
	levels = [$LevelSlot1,$LevelSlot2]
	var mods_path
	var mods = System.get_mods_folders("user://mods")
	for mod_name in mods:
		var full_path = "user://mods/%s/level_selection.tscn" % mod_name
		#res://Mods/Level/
		var packed_scene = load(full_path)
		if packed_scene and packed_scene is PackedScene:
			var instance = packed_scene.instantiate()
			print(instance)
			if instance:
				levels.append(instance)
				add_child(instance)  
		else:
			push_error("Path does not lead to a PackedScene")
	levels.append($Soon)
	$Fade_effect.show()
	$Fade_effect/AnimationPlayer.play("fade_out")
	#levels = [Slot_1,Slot_2,Slot_3]
	positions = [slot_1_marker.global_position,slot_2_marker.global_position,slot_3_marker.global_position, slot_4_marker.global_position, slot_0_marker.global_position]
	label_positions = [slot_1_marker_label.global_position, slot_2_marker_label.global_position, slot_3_marker_label.global_position, slot_4_marker_label.global_position, slot_0_marker.global_position]
	Global.slected_level_path = levels[1].level_path

func LevelOptions(delta):
	var speed = 7.0
	var target_sprite_pos
	var target_label_pos
	for i in levels.size():
		var level = levels[i]
		if i > 4:
			target_sprite_pos = level_targets[4]["sprite_pos"]
			target_label_pos = level_targets[4]["label_pos"]
		else:
			target_sprite_pos = level_targets[i]["sprite_pos"]
			target_label_pos = level_targets[i]["label_pos"]
		level.level_slot_sprite.global_position = level.level_slot_sprite.global_position.lerp(target_sprite_pos, delta * speed)
		if level.level_label:
			level.level_label.global_position = level.level_label.global_position.lerp(target_label_pos, delta * speed)
	# Modulate opacity
		if i == middle_index:
			levels[i].level_slot_sprite.modulate.a = 1.0
			levels[i].level_slot_sprite.z_index = 0
			if level.level_label:
				levels[i].level_label.z_index = 0
				levels[i].level_label.modulate.a = 1.0
		elif i > 4:
			levels[i].level_slot_sprite.modulate.a = 0.0
			levels[i].level_slot_sprite.z_index = -1
			if level.level_label:
				levels[i].level_label.z_index = -1
				levels[i].level_label.modulate.a = 0.0
		else:
			levels[i].level_slot_sprite.modulate.a = 0.5
			levels[i].level_slot_sprite.z_index = -1
			if level.level_label:
				levels[i].level_label.modulate.a = 0.5
				levels[i].level_label.z_index = -1

func ShiftArrayLeft():
	$"LevelSlot2/Menu Arrow".stop()
	$"LevelSlot2/Menu Arrow".play()
	left_arrow_up.color = Color(0.35, 0.739, 0.76)
	left_arrow_down.color = Color(0.352, 0.589, 0.69)
	
	var last = levels.pop_back()
	levels.insert(0, last)
	if levels[middle_index + 1].level_audio != null:
		levels[middle_index + 1].level_audio.stop()
	if levels[middle_index].level_audio != null:
		levels[middle_index].level_audio.play()
	
	await get_tree().create_timer(0.3).timeout
	
	left_arrow_up.color = Color(0.84, 0.84, 0.84)
	left_arrow_down.color = Color(0.587, 0.604, 0.66)
	
func ShiftArrayRight():
	$"LevelSlot2/Menu Arrow".stop()
	$"LevelSlot2/Menu Arrow".play()
	right_arrow_up.color = Color(0.35, 0.739, 0.76)
	right_arrow_down.color = Color(0.352, 0.589, 0.69)
	
	var first = levels.pop_front()
	levels.append(first)
	
	if levels[middle_index - 1].level_audio != null:
		levels[middle_index - 1].level_audio.stop()
	if levels[middle_index].level_audio != null:
		levels[middle_index].level_audio.play()
	
	
	await get_tree().create_timer(0.3).timeout
	
	right_arrow_up.color = Color(0.84, 0.84, 0.84)
	right_arrow_down.color = Color(0.587, 0.604, 0.66)

func _process(delta: float) -> void:
	Global.slected_level_path = levels[middle_index].level_path
	if (levels.size() / 2) % 2 == 0:
		middle_index = (levels.size() / 2) - 1
	else:
		middle_index = (levels.size() / 2)
	LevelOptions(delta)
	if Input.is_action_just_pressed("ui_left") and !selection_lock:
		ShiftArrayLeft()
		
	if Input.is_action_just_pressed("ui_right") and !selection_lock:
		ShiftArrayRight()
		
	if Input.is_action_just_pressed("ui_accept") and !selection_lock:
		selection_lock = true
		$"VBoxContainer/MarginContainer2/Menu Select".play()
		$Fade_effect.show()
		$Fade_effect/Fade_timer.start()
		$Fade_effect/AnimationPlayer.play("fade_in")
		await $Fade_effect/Fade_timer.timeout
		if levels[middle_index] != $Soon:
			$"Preset Selection Screen".show()
			$Fade_effect/AnimationPlayer.play("fade_out")
		else:
			get_tree().change_scene_to_file("res://System/UI/Level Selection Screen/Level selection screen.tscn")
	if Input.is_action_just_pressed("ui_cancel") and !selection_lock:
		if $"Preset Selection Screen".is_visible_in_tree():
			$"Preset Selection Screen".hide()
		else:
			selection_lock = true
			$"VBoxContainer/MarginContainer2/Menu Exit".play()
			$Fade_effect.show()
			$Fade_effect/Fade_timer.start()
			$Fade_effect/AnimationPlayer.play("fade_in")
			await $Fade_effect/Fade_timer.timeout
			get_tree().change_scene_to_file("res://System/UI/Character Selection Screen/Character Selection Screen.tscn")


func _on_confirm_2_pressed() -> void:
	System.load_screen_to_scene(Global.slected_level_path)
