extends Interactable
class_name RoomExit
## 房间出口，按 [E] 后切换到目标房间

@export var target_room_id: String = ""
@export var target_spawn_point: String = "SpawnPoint"
@export var blocked: bool = false
@export var blocked_message: String = "前方被碎石堵住"


func _ready() -> void:
	if interaction_text == "检查":
		interaction_text = "前进"
	prompt_color = Color(0.4, 0.8, 1.0)
	super._ready()


func _on_interacted() -> void:
	if blocked:
		_show_blocked_message()
		return
	
	if target_room_id.is_empty():
		print("[RoomExit] 目标房间未设置")
		return
	
	RoomManager.change_room(target_room_id, target_spawn_point)


func _show_blocked_message() -> void:
	var dialog_box := get_tree().get_first_node_in_group("dialog_box")
	if dialog_box and dialog_box.has_method("show_message"):
		dialog_box.show_message(blocked_message)
	else:
		print("[RoomExit] %s" % blocked_message)
