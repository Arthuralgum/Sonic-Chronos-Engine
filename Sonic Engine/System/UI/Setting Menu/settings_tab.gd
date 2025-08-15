extends Control
var audio_tab_visible: bool = false
var video_tab_visible: bool = false
var controls_tab_visible: bool = false
var gameplay_tab_visible: bool = false
enum gameplay_tab {Default, Preset1, Preset2, Preset3}
var current_gameplay_tab := gameplay_tab.Default
enum preset_selected {Default, Preset1, Preset2, Preset3}
var current_preset_selected := preset_selected.Default
var selected_index := 0
var menu_options := []
var options_panels := []
var previous_normal

func ShowAudioTab():
	$Audio/Panel.show()
	audio_tab_visible = true

func HideAudioTab():
	$Audio/Panel.hide()
	audio_tab_visible = false

func ShowVideoTab():
	$Video/Panel.show()
	video_tab_visible = true

func HideVideoTab():
	$Video/Panel.hide()
	video_tab_visible = false

func ShowControlTab():
	$Controls/Panel.show()
	controls_tab_visible = true

func HideControlTab():
	$Controls/Panel.hide()
	controls_tab_visible = false

func ShowGameplayTab():
	$Gameplay/Panel.show()
	gameplay_tab_visible = true

func HideGameplayTab():
	$Gameplay/Panel.hide()
	gameplay_tab_visible = false

func ShowAudioHSlideText():
	$Audio/Panel/HSlider/Percentage.text = str(int($Audio/Panel/HSlider.value)) + "%"
	$Audio/Panel/HSlider2/Percentage.text = str(int($Audio/Panel/HSlider2.value)) + "%"
	$Audio/Panel/HSlider3/Percentage.text = str(int($Audio/Panel/HSlider3.value)) + "%"

func ShowVideoFPSText():
	var fps: String
	if $Video/Panel/HSlider.value == 0:
		fps = "30"
	elif $Video/Panel/HSlider.value == 2:
		fps = "120"
	else:
		fps = "60"
	$Video/Panel/FPS.text = "FPS: " + fps

func HandleGameplayTab():
	if current_gameplay_tab == gameplay_tab.Default:
		$Gameplay/Panel/Default/DefaultTab.show()
		$Gameplay/Panel/Preset1/Preset1Tab.hide()
		$Gameplay/Panel/Preset2/Preset2Tab.hide()
		$Gameplay/Panel/Preset3/Preset3Tab.hide()
		GameplayDefaultPanelSettings()
		$Gameplay/Panel/Default.button_pressed = true
	elif current_gameplay_tab == gameplay_tab.Preset1:
		$Gameplay/Panel/Preset1/Preset1Tab.show()
		$Gameplay/Panel/Default/DefaultTab.hide()
		$Gameplay/Panel/Preset2/Preset2Tab.hide()
		$Gameplay/Panel/Preset3/Preset3Tab.hide()
		$Gameplay/Panel/Preset1.button_pressed = true
	elif current_gameplay_tab == gameplay_tab.Preset2:
		$Gameplay/Panel/Preset2/Preset2Tab.show()
		$Gameplay/Panel/Default/DefaultTab.hide()
		$Gameplay/Panel/Preset1/Preset1Tab.hide()
		$Gameplay/Panel/Preset3/Preset3Tab.hide()
		$Gameplay/Panel/Preset2.button_pressed = true
	elif current_gameplay_tab == gameplay_tab.Preset3:
		$Gameplay/Panel/Preset3/Preset3Tab.show()
		$Gameplay/Panel/Default/DefaultTab.hide()
		$Gameplay/Panel/Preset1/Preset1Tab.hide()
		$Gameplay/Panel/Preset2/Preset2Tab.hide()
		$Gameplay/Panel/Preset3.button_pressed = true
		

func GameplayDefaultPanelSettings():
	if $Gameplay/Panel/Default/DefaultTab/OptionButton.selected == 0:
		$Gameplay/Panel/Default/DefaultTab/Level.visible = true
		$Gameplay/Panel/Default/DefaultTab/Classic.visible = false
		$Gameplay/Panel/Default/DefaultTab/Adventure.visible = false
		$Gameplay/Panel/Default/DefaultTab/Boost.visible = false
	elif $Gameplay/Panel/Default/DefaultTab/OptionButton.selected == 1:
		$Gameplay/Panel/Default/DefaultTab/Level.visible = false
		$Gameplay/Panel/Default/DefaultTab/Classic.visible = true
		$Gameplay/Panel/Default/DefaultTab/Adventure.visible = false
		$Gameplay/Panel/Default/DefaultTab/Boost.visible = false
	elif $Gameplay/Panel/Default/DefaultTab/OptionButton.selected == 2:
		$Gameplay/Panel/Default/DefaultTab/Level.visible = false
		$Gameplay/Panel/Default/DefaultTab/Classic.visible = false
		$Gameplay/Panel/Default/DefaultTab/Adventure.visible = true
		$Gameplay/Panel/Default/DefaultTab/Boost.visible = false
	elif $Gameplay/Panel/Default/DefaultTab/OptionButton.selected == 3:
		$Gameplay/Panel/Default/DefaultTab/Level.visible = false
		$Gameplay/Panel/Default/DefaultTab/Classic.visible = false
		$Gameplay/Panel/Default/DefaultTab/Adventure.visible = false
		$Gameplay/Panel/Default/DefaultTab/Boost.visible = true

func SelectOptions():
	if Input.is_action_just_pressed("ui_right"):
		selected_index = (selected_index + 1) % menu_options.size()
	elif Input.is_action_just_pressed("ui_left"):
		selected_index = (selected_index - 1 + menu_options.size()) % menu_options.size()
	for button in menu_options:
		if button.is_hovered():
			selected_index = menu_options.find(button)
			break
	if Input.is_action_just_pressed("ui_accept"):
		menu_options[selected_index].button_pressed = true
func UpdateButtonVisuals():
	for i in range(menu_options.size()):
		if i == selected_index:
			menu_options[i].texture_normal = menu_options[i].texture_hover
		else:
			menu_options[i].texture_normal = previous_normal

func _ready() -> void:
	menu_options = [$Video,$Audio,$Controls,$Gameplay]
	options_panels = [$Video/Panel,$Audio/Panel,$Controls/Panel,]
	previous_normal = menu_options[0].texture_normal

func _process(delta: float) -> void:
	UpdateButtonVisuals()
	SelectOptions()
	if audio_tab_visible:
		ShowAudioHSlideText()
	elif video_tab_visible:
		ShowVideoFPSText()
	elif gameplay_tab_visible:
		HandleGameplayTab()
	if Input.is_action_just_pressed("OpenMenu") and $".".is_visible_in_tree():
		if $"../Buttons" and $"../Label":
			$"../Label".show()
			$"../Buttons".show()
			hide()
		else:
			get_tree().change_scene_to_file("res://System/UI/LevelMenu.tscn")
			push_warning("Settings tab not in level menu")

func _on_audio_toggled(toggled_on: bool) -> void:
	if audio_tab_visible == false:
		ShowAudioTab()
		HideVideoTab()
		HideControlTab()
		HideGameplayTab()
	else:
		HideAudioTab()



func _on_video_toggled(toggled_on: bool) -> void:
	if video_tab_visible == false:
		ShowVideoTab()
		HideAudioTab()
		HideControlTab()
		HideGameplayTab()
	else:
		HideVideoTab()


func _on_controls_toggled(toggled_on: bool) -> void:
	if controls_tab_visible == false:
		ShowControlTab()
		HideVideoTab()
		HideAudioTab()
		HideGameplayTab()
	else:
		HideControlTab()


func _on_gameplay_toggled(toggled_on: bool) -> void:
	if gameplay_tab_visible == false:
		ShowGameplayTab()
		HideVideoTab()
		HideAudioTab()
		HideControlTab()
	else:
		HideGameplayTab()
		

func _on_gameplay_default_toggled(toggled_on: bool) -> void:
	current_gameplay_tab = gameplay_tab.Default

func _on_gameplay_preset_1_toggled(toggled_on: bool) -> void:
	current_gameplay_tab = gameplay_tab.Preset1

func _on_gameplay_preset_2_toggled(toggled_on: bool) -> void:
	current_gameplay_tab = gameplay_tab.Preset2

func _on_gameplay_preset_3_toggled(toggled_on: bool) -> void:
	current_gameplay_tab = gameplay_tab.Preset3
	
