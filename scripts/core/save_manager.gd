extends Node
## SaveManager autoload - handles local save/load functionality

signal save_completed(success: bool)
signal load_completed(success: bool)

const SAVE_PATH := "user://save_data.json"


func save_game() -> bool:
	var player_pos := Vector2.ZERO
	var player_node := get_tree().get_first_node_in_group("player")
	if player_node == null:
		player_node = _find_player_node()
	if player_node:
		player_pos = player_node.global_position
	
	var save_data := {
		"version": 1,
		"timestamp": Time.get_unix_time_from_system(),
		"player": GameManager.player_data.duplicate(true),
		"player_position": {"x": player_pos.x, "y": player_pos.y},
		"scene": get_tree().current_scene.scene_file_path if get_tree().current_scene else ""
	}
	
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))
		file.close()
		save_completed.emit(true)
		print("[SaveManager] 存档成功: 位置 (", player_pos.x, ", ", player_pos.y, ")")
		return true
	
	save_completed.emit(false)
	return false


func _find_player_node() -> Node2D:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0] as Node2D
	var root := get_tree().current_scene
	if root:
		return root.find_child("Player", true, false) as Node2D
	return null


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
	
	if save_data.has("player_position"):
		var pos_data: Dictionary = save_data.player_position
		var saved_pos := Vector2(float(pos_data.get("x", 0)), float(pos_data.get("y", 0)))
		_restore_player_position(saved_pos)
	
	print("[SaveManager] 读档成功")
	load_completed.emit(true)
	return true


func _restore_player_position(pos: Vector2) -> void:
	var player_node := get_tree().get_first_node_in_group("player")
	if player_node == null:
		player_node = _find_player_node()
	if player_node:
		player_node.global_position = pos
		print("[SaveManager] 玩家位置已恢复: (", pos.x, ", ", pos.y, ")")


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
