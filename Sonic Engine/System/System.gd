extends Node


#Loading Screen

func load_screen_to_scene(target: String) -> void:
	var loading_screen = preload("res://System/UI/Loading Screen/loading_screen.tscn").instantiate()
	loading_screen.next_scene_path = target
	if get_tree().current_scene != null:
		get_tree().current_scene.add_child(loading_screen)


#Modding

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

#Stage transitions

func ExitStageTo(next_scene: String):
	#Reseting the stage configs
	Global.EnemyPostitions.clear()
	Global.rails_positions.clear()
	Global.Rings = 0
	Global.Score = 0
	Global.Energy = 0.0
	#Changing to the next scene that you select
	get_tree().change_scene_to_file(next_scene)


#Save & Load Data

func save_all_presets(save_path: String, preset_data):
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_var(preset_data)

func load_all_presets(save_path: String, data):
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var new_data = file.get_var()
		return new_data
	else:
		save_all_presets(save_path,data) # create file if missing
		return data


enum presets {Default,Preset1,Preset2,Preset3}
var selected_preset := presets.Default
