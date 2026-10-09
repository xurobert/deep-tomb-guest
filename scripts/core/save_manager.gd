extends Node
## SaveManager autoload - handles local save/load functionality

signal save_completed(success: bool)
signal load_completed(success: bool)

const SAVE_PATH := "user://save_data.json"
const DEFAULT_ROOM := "ch0_hall"

var cleared: Dictionary = {}


func save_game(save_point_id: String = "") -> bool:
	GameManager.restore_full_hp()
	GameManager.reset_overload()
	
	var player_pos := Vector2.ZERO
	var player_node := get_tree().get_first_node_in_group("player")
	if player_node == null:
		player_node = _find_player_node()
	if player_node:
		player_pos = player_node.global_position
	
	var current_room_id := RoomManager.get_current_room_id() if RoomManager else DEFAULT_ROOM
	if current_room_id.is_empty():
		current_room_id = DEFAULT_ROOM
	
	var save_data := {
		"version": 1,
		"timestamp": Time.get_unix_time_from_system(),
		"player": GameManager.player_data.duplicate(true),
		"player_position": {"x": player_pos.x, "y": player_pos.y},
		"scene": get_tree().current_scene.scene_file_path if get_tree().current_scene else "",
		"flags": GameManager.flags.duplicate(true),
		"save_point_id": save_point_id,
		"room_id": current_room_id,
		"cleared": cleared.duplicate(true)
	}
	
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))
		file.close()
		save_completed.emit(true)
		print("[SaveManager] 存档成功: 位置 (", player_pos.x, ", ", player_pos.y, "), HP已回满, 失控已清零")
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
	
	var saved_flags: Variant = save_data.get("flags", {})
	if typeof(saved_flags) == TYPE_DICTIONARY:
		GameManager.flags = saved_flags.duplicate(true)
	else:
		GameManager.flags = {}
	
	var saved_cleared: Variant = save_data.get("cleared", {})
	if typeof(saved_cleared) == TYPE_DICTIONARY:
		cleared = saved_cleared.duplicate(true)
	else:
		cleared = {}
	
	var room_id: String = str(save_data.get("room_id", ""))
	if room_id.is_empty():
		room_id = DEFAULT_ROOM
	
	if RoomManager:
		RoomManager.change_room_instant(room_id)
	
	if save_data.has("player_position"):
		var pos_data: Dictionary = save_data.player_position
		var saved_pos := Vector2(float(pos_data.get("x", 0)), float(pos_data.get("y", 0)))
		call_deferred("_restore_player_position", saved_pos)
	
	print("[SaveManager] 读档成功，房间: %s" % room_id)
	load_completed.emit(true)
	return true


func handle_combat_defeat() -> void:
	if has_save():
		load_game()
		print("[SaveManager] 败后读档，回到魂灯位置")
	else:
		GameManager.restore_full_hp()
		print("[SaveManager] 无存档，回满HP留在原地")


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


func mark_cleared(node_name: String) -> void:
	var room_id := RoomManager.get_current_room_id() if RoomManager else ""
	if room_id.is_empty():
		return
	var key := room_id + "/" + node_name
	cleared[key] = true
	print("[SaveManager] 标记为已清除: %s" % key)


func is_cleared(node_name: String, room_id: String = "") -> bool:
	if room_id.is_empty() and RoomManager:
		room_id = RoomManager.get_current_room_id()
	if room_id.is_empty():
		return false
	var key := room_id + "/" + node_name
	return cleared.get(key, false)
