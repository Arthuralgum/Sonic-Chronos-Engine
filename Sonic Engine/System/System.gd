extends Node


func load_screen_to_scene(target: String) -> void:
	var loading_screen = preload("res://System/UI/Loading Screen/loading_screen.tscn").instantiate()
	loading_screen.next_scene_path = target
	if get_tree().current_scene != null:
		get_tree().current_scene.add_child(loading_screen)

func get_mods_folders(path: String) -> Array:
	var dirs: Array = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir() and file_name != "." and file_name != "..":
				dirs.append(file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	return dirs

func load_mod_scene(mod_path: String, mod_folder: String, scene_file: String) -> PackedScene:
	var full_path = mod_path + mod_folder + "/" + scene_file
	var scene = load(full_path)
	if scene and scene is PackedScene:
		return scene
	else:
		push_error("Failed to load mod scene: " + full_path)
		return null

func ExitStageTo(next_scene: String):
	#Reseting the stage configs
	Global.EnemyPostitions.clear()
	Global.Rings = 0
	Global.Score = 0
	Global.Energy = 0.0
	#Changing to the next scene that you select
	get_tree().change_scene_to_file(next_scene)
	
enum presets {Default,Preset1,Preset2,Preset3}
var selected_preset := presets.Default
