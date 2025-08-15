extends CanvasLayer
@onready var animations: AnimationPlayer = $Animations
var menu_options := []
var previous_normal 
@onready var resume: TextureButton = $Buttons/Resume/TextureButton
@onready var restart: TextureButton = $Buttons/Restart/TextureButton
@onready var settings: TextureButton = $Buttons/Settings/TextureButton
@onready var main_menu: TextureButton = $Buttons/MainMenu/TextureButton
var selected_index := 0

func PauseMenu():
	show()
	$Buttons.show()
	$BG.show()
	$Label.show()
	animations.play("Entrance")
	get_tree().paused = true

func UnpauseMenu():
	animations.play_backwards("Entrance")
	await animations.animation_finished
	$Buttons.hide()
	$BG.hide()
	$Label.hide()
	get_tree().paused = false

func SelectOptions():
	if Input.is_action_just_pressed("ui_down"):
		selected_index = (selected_index + 1) % menu_options.size()
	elif Input.is_action_just_pressed("ui_up"):
		selected_index = (selected_index - 1 + menu_options.size()) % menu_options.size()
	for button in menu_options:
		if button.is_hovered():
			selected_index = menu_options.find(button)
			break
	if Input.is_action_just_pressed("ui_accept"):
		menu_options[selected_index].button_pressed = true
		ExecuteMenuButton()
	UpdateButtonVisuals()

func UpdateButtonVisuals():
	for i in range(menu_options.size()):
		if i == selected_index:
			menu_options[i].texture_normal = menu_options[i].texture_hover
		else:
			menu_options[i].texture_normal = previous_normal
			menu_options[i].button_pressed = false

func _ready() -> void:
	menu_options = [resume,restart,settings,main_menu]
	previous_normal = menu_options[0].texture_normal

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("OpenMenu"):
		if get_tree().paused == true and !$"Settings Tab".is_visible_in_tree():
			UnpauseMenu()
		else:
			PauseMenu()
	if get_tree().paused == true and !$"Settings Tab".is_visible_in_tree():
		SelectOptions()

func ExecuteMenuButton():
	if resume.button_pressed:
		UnpauseMenu()
		await get_tree().create_timer(0.1).timeout
		resume.button_pressed = false
	elif restart.button_pressed:
		Global.game_over = true
		get_tree().paused = false
		await get_tree().create_timer(0.1).timeout
		restart.button_pressed = false
		System.ExitStageTo("res://System/UI/Level Selection Screen/Level selection screen.tscn")
	elif settings.button_pressed:
		await get_tree().create_timer(0.1).timeout
		settings.button_pressed = false
		$"Settings Tab".show()
		$Buttons.hide()
		$Label.hide()
	elif main_menu.button_pressed:
		get_tree().paused = false
		await get_tree().create_timer(0.1).timeout
		main_menu.button_pressed = false
	else:
		return ("Option not Found")

func _on_texture_button_pressed() -> void:
	ExecuteMenuButton()
