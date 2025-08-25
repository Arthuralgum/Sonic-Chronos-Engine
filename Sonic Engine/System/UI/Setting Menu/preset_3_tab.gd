extends Control

var save_path := "user://preset_data"
var presets := {
	"preset1": {},
	"preset2": {},
	"preset3": {}
}
func _ready() -> void:
	presets = System.load_all_presets(save_path, presets)
	apply_preset_ui("preset1")
	apply_preset_ui("preset2")
	apply_preset_ui("preset3")

func _process(delta: float) -> void:
	if $Panel/Preset1/Preset1Tab/ScrollContainer/VBoxContainer/HBoxContainer3/VBoxContainer/PresetButton.button_pressed or $Panel/Preset2/Preset2Tab/ScrollContainer/VBoxContainer/HBoxContainer3/VBoxContainer/PresetButton.button_pressed or $Panel/Preset3/Preset3Tab/ScrollContainer/VBoxContainer/HBoxContainer3/VBoxContainer/PresetButton.button_pressed:
		read_preset_from_ui("preset1")
		read_preset_from_ui("preset2")
		read_preset_from_ui("preset3")
		System.save_all_presets(save_path, presets)

# SAVE & LOAD

#func save_all_presets():
	#var file = FileAccess.open(save_path, FileAccess.WRITE)
	#file.store_var(presets)
#func load_all_presets():
	#if FileAccess.file_exists(save_path):
		#var file = FileAccess.open(save_path, FileAccess.READ)
		#presets = file.get_var()
	#else:
		#save_all_presets() # create file if missing

# UI -> DATA

func read_preset_from_ui(preset_name: String):
	var tab_path = get_node(get_tab_path(preset_name))
	presets[preset_name] = {
		"spindash": tab_path.get_node("HBoxContainer/CheckButton").button_pressed,
		"peelout": tab_path.get_node("HBoxContainer/CheckButton2").button_pressed,
		"dropdash": tab_path.get_node("HBoxContainer/CheckButton3").button_pressed,
		"bounce": tab_path.get_node("HBoxContainer2/CheckButton").button_pressed,
		"homing_attack": tab_path.get_node("HBoxContainer2/CheckButton2").button_pressed,
		"boost": tab_path.get_node("CheckButton").button_pressed,
		"topspeed": tab_path.get_node("HBoxContainer4/HBoxContainer3/SpinBox").value,
		"acceleration": tab_path.get_node("HBoxContainer4/HBoxContainer/SpinBox").value,
		"jump_velocity": tab_path.get_node("HBoxContainer4/HBoxContainer2/SpinBox").value
	}

# DATA -> UI

func apply_preset_ui(preset_name: String):
	if not presets.has(preset_name):
		return
	var data = presets[preset_name]
	var tab_path = get_node(get_tab_path(preset_name))
	tab_path.get_node("HBoxContainer/CheckButton").button_pressed = data.get("spindash", false)
	tab_path.get_node("HBoxContainer/CheckButton2").button_pressed = data.get("peelout", false)
	tab_path.get_node("HBoxContainer/CheckButton3").button_pressed = data.get("dropdash", false)
	tab_path.get_node("HBoxContainer2/CheckButton").button_pressed = data.get("bounce", false)
	tab_path.get_node("HBoxContainer2/CheckButton2").button_pressed = data.get("homing_attack", false)
	tab_path.get_node("CheckButton").button_pressed = data.get("boost", false)
	tab_path.get_node("HBoxContainer4/HBoxContainer3/SpinBox").value = data.get("topspeed", 1200)
	tab_path.get_node("HBoxContainer4/HBoxContainer/SpinBox").value = data.get("acceleration", 2)
	tab_path.get_node("HBoxContainer4/HBoxContainer2/SpinBox").value = data.get("jump_velocity", 400)

# Helper

func get_tab_path(preset_name: String) -> NodePath:
	match preset_name:
		"preset1":
			return "Panel/Preset1/Preset1Tab/ScrollContainer/VBoxContainer"
		"preset2":
			return "Panel/Preset2/Preset2Tab/ScrollContainer/VBoxContainer"
		"preset3":
			return "Panel/Preset3/Preset3Tab/ScrollContainer/VBoxContainer"
	return ""
