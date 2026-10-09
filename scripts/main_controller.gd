extends Node2D
## 主场景控制器 - 负责初始化和房间加载


func _ready() -> void:
	call_deferred("_initialize")


func _initialize() -> void:
	if SaveManager.has_save():
		return
	
	RoomManager.change_room_instant(RoomManager.DEFAULT_ROOM)
