extends Node
## SaveManager autoload - handles local save/load functionality

signal save_completed(success: bool)
signal load_completed(success: bool)

const SAVE_PATH := "user://save_data.json"


func save_game() -> bool:
	var save_data := {
		"version": 1,
		"timestamp": Time.get_unix_time_from_system(),
		"player": GameManager.player_data.duplicate(true),
		"scene": get_tree().current_scene.scene_file_path if get_tree().current_scene else ""
	}
	
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))
		file.close()
		save_completed.emit(true)
		return true
	
	save_completed.emit(false)
	return false


func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		load_completed.emit(false)
		return false
	
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		load_completed.emit(false)
		return false
	
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		file.close()
		load_completed.emit(false)
		return false
	
	file.close()
	
	var save_data: Dictionary = json.data
	if save_data.has("player"):
		for key in save_data.player.keys():
			GameManager.player_data[key] = save_data.player[key]
	
	load_completed.emit(true)
	return true


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
