extends Node
## RoomManager autoload - handles room transitions and spawning
class_name RoomManagerClass

signal room_changed(new_room_id: String)
signal transition_started
signal transition_finished

const FADE_DURATION := 0.3
const DEFAULT_ROOM := "ch0_hall"
const ROOMS_PATH := "res://scenes/rooms/"

var current_room_id: String = ""
var current_room_node: Node2D = null
var _transitioning: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func get_current_room_id() -> String:
	return current_room_id


func change_room(room_id: String, spawn_point_name: String = "SpawnPoint") -> void:
	if _transitioning:
		return
	
	_transitioning = true
	transition_started.emit()
	
	await _fade_out()
	
	_unload_current_room()
	
	var success := _load_room(room_id)
	if not success:
		print("[RoomManager] 加载房间失败: %s，回退到默认房间" % room_id)
		success = _load_room(DEFAULT_ROOM)
		if success:
			room_id = DEFAULT_ROOM
	
	if success:
		current_room_id = room_id
		_move_player_to_spawn(spawn_point_name)
		room_changed.emit(room_id)
	
	await _fade_in()
	
	_transitioning = false
	transition_finished.emit()


func change_room_instant(room_id: String, spawn_point_name: String = "SpawnPoint") -> bool:
	_unload_current_room()
	
	var success := _load_room(room_id)
	if not success:
		print("[RoomManager] 加载房间失败: %s，回退到默认房间" % room_id)
		success = _load_room(DEFAULT_ROOM)
		if success:
			room_id = DEFAULT_ROOM
	
	if success:
		current_room_id = room_id
		_move_player_to_spawn(spawn_point_name)
		room_changed.emit(room_id)
		return true
	
	return false


func _load_room(room_id: String) -> bool:
	var room_path := ROOMS_PATH + room_id + ".tscn"
	if not ResourceLoader.exists(room_path):
		print("[RoomManager] 房间文件不存在: %s" % room_path)
		return false
	
	var room_scene: PackedScene = load(room_path)
	if room_scene == null:
		print("[RoomManager] 加载房间场景失败: %s" % room_path)
		return false
	
	current_room_node = room_scene.instantiate()
	
	var main_scene := get_tree().current_scene
	if main_scene:
		var room_container := main_scene.get_node_or_null("RoomContainer")
		if room_container:
			room_container.add_child(current_room_node)
		else:
			main_scene.add_child(current_room_node)
			main_scene.move_child(current_room_node, 0)
	
	print("[RoomManager] 已加载房间: %s" % room_id)
	return true


func _unload_current_room() -> void:
	if current_room_node and is_instance_valid(current_room_node):
		current_room_node.queue_free()
		current_room_node = null


func _move_player_to_spawn(spawn_point_name: String) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return
	
	if current_room_node == null:
		return
	
	var spawn_point := current_room_node.get_node_or_null(spawn_point_name) as Marker2D
	if spawn_point:
		player.global_position = spawn_point.global_position
		print("[RoomManager] 玩家移动到出生点: %s (%s)" % [spawn_point_name, spawn_point.global_position])
	else:
		var default_spawn := current_room_node.get_node_or_null("SpawnPoint") as Marker2D
		if default_spawn:
			player.global_position = default_spawn.global_position
			print("[RoomManager] 使用默认出生点: SpawnPoint (%s)" % default_spawn.global_position)


func restore_player_position(pos: Vector2) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.global_position = pos
		print("[RoomManager] 玩家位置已恢复: %s" % pos)


func _fade_out() -> void:
	var fade_rect := _get_or_create_fade_rect()
	if fade_rect == null:
		return
	
	var tween := create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, FADE_DURATION)
	await tween.finished


func _fade_in() -> void:
	var fade_rect := _get_or_create_fade_rect()
	if fade_rect == null:
		return
	
	var tween := create_tween()
	tween.tween_property(fade_rect, "color:a", 0.0, FADE_DURATION)
	await tween.finished


func _get_or_create_fade_rect() -> ColorRect:
	var main_scene := get_tree().current_scene
	if main_scene == null:
		return null
	
	var fade_layer := main_scene.get_node_or_null("FadeLayer")
	if fade_layer == null:
		fade_layer = CanvasLayer.new()
		fade_layer.name = "FadeLayer"
		fade_layer.layer = 99
		main_scene.add_child(fade_layer)
	
	var fade_rect := fade_layer.get_node_or_null("FadeRect") as ColorRect
	if fade_rect == null:
		fade_rect = ColorRect.new()
		fade_rect.name = "FadeRect"
		fade_rect.color = Color(0, 0, 0, 0)
		fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fade_layer.add_child(fade_rect)
	
	return fade_rect
