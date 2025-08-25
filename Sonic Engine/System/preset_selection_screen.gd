extends Control
var preset_data_path := "user://preset_data"
var preset_options := []
var previous_normal
var selected_index := 0
var presets := {
	"preset1": {},
	"preset2": {},
	"preset3": {}
}
func _ready() -> void:
	preset_options = [$Default,$Preset1,$Preset2,$Preset3]
	previous_normal = preset_options[0].texture_normal
	$Default.button_pressed = true

func _process(delta: float) -> void:
	if $".".is_visible_in_tree():
		presets = System.load_all_presets(preset_data_path, presets)
		SelectOptions()
		UpdateButtonVisuals()
		if $Default.button_pressed == true:
			System.selected_preset = System.presets.Default
			$Default/Description.show()
			$Configs.hide()
		else:
			$Default/Description.hide()
			$Configs.show()
		if $Preset1.button_pressed == true:
			apply_preset_ui("preset1")
			System.selected_preset = System.presets.Preset1
		elif $Preset2.button_pressed == true:
			apply_preset_ui("preset2")
			System.selected_preset = System.presets.Preset2
		elif $Preset3.button_pressed == true:
			apply_preset_ui("preset3")
			System.selected_preset = System.presets.Preset3
		else:
			push_error("Aditional button not configured...?")
			return

func SelectOptions():
	if Input.is_action_just_pressed("ui_right"):
		selected_index = (selected_index + 1) % preset_options.size()
	elif Input.is_action_just_pressed("ui_left"):
		selected_index = (selected_index - 1 + preset_options.size()) % preset_options.size()
	for button in preset_options:
		if button.is_hovered():
			selected_index = preset_options.find(button)
			break
	if Input.is_action_just_pressed("ui_accept"):
		preset_options[selected_index].button_pressed = true

func UpdateButtonVisuals():
	for i in range(preset_options.size()):
		if i == selected_index:
			preset_options[i].texture_normal = preset_options[i].texture_hover
		else:
			preset_options[i].texture_normal = previous_normal

func apply_preset_ui(preset_name: String):
	if not presets.has(preset_name):
		return
	var data = presets[preset_name]
	var spindash_flag :bool = data.get("spindash", false)
	if spindash_flag == true:
		$Configs/SpindashCheck.play("True")
	else:
		$Configs/SpindashCheck.play("False")
	var peelout_flag :bool = data.get("peelout", false)
	if peelout_flag == true:
		$Configs/PeelOutCheck.play("True")
	else:
		$Configs/PeelOutCheck.play("False")
	var dropdash_flag :bool = data.get("dropdash", false)
	if dropdash_flag == true:
		$Configs/DropdashCheck.play("True")
	else:
		$Configs/DropdashCheck.play("False")
	var bounce_flag :bool = data.get("bounce", false)
	if bounce_flag == true:
		$Configs/BounceCheck.play("True")
	else:
		$Configs/BounceCheck.play("False")
	var homing_attack_flag :bool = data.get("homing_attack", false)
	if homing_attack_flag == true:
		$Configs/HommingAttackCheck.play("True")
	else:
		$Configs/HommingAttackCheck.play("False")
	var boost_flag :bool = data.get("boost", false)
	if boost_flag == true:
		$Configs/BoostCheck.play("True")
	else:
		$Configs/BoostCheck.play("False")
	$Configs/TopSpeed.text = "TopSpeed: " + str(data.get("topspeed", 1200))
	$Configs/Acceleration.text = "Acceleration: " + str(data.get("acceleration", 2))
	$"Configs/Jump Velocity".text = "Jump Velocity: " + str(data.get("jump_velocity", 400))
