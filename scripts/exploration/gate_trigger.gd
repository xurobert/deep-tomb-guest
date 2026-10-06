extends Interactable
class_name GateTrigger
## 层门触发器 - 带确认框和开门动画的房间切换

@export var target_room_id: String = ""
@export var target_spawn_point: String = "SpawnPoint"
@export var confirm_message: String = "踏入深处？"
@export var gate_opened_flag: String = ""
@export var flags_to_set_on_pass: Dictionary = {}
@export var area_banner_text: String = ""

@onready var gate_sprite: AnimatedSprite2D = $GateSprite if has_node("GateSprite") else null

var _is_opened: bool = false


func _ready() -> void:
	if interaction_text == "检查":
		interaction_text = "进入"
	prompt_color = Color(0.8, 0.6, 1.0)
	super._ready()
	
	call_deferred("_restore_from_flags")


func _restore_from_flags() -> void:
	if not gate_opened_flag.is_empty() and GameManager.has_flag(gate_opened_flag):
		_set_opened_state_instant()


func _on_interacted() -> void:
	if _is_opened:
		_do_transition()
	else:
		_show_confirm_dialog()


func _show_confirm_dialog() -> void:
	GameManager.show_confirm(confirm_message, _on_confirmed)


func _on_confirmed() -> void:
	_play_open_animation()


func _play_open_animation() -> void:
	if gate_sprite and gate_sprite.sprite_frames:
		gate_sprite.play("open")
		gate_sprite.animation_finished.connect(_on_open_animation_finished, CONNECT_ONE_SHOT)
	else:
		_on_open_animation_finished()


func _on_open_animation_finished() -> void:
	_is_opened = true
	
	if not gate_opened_flag.is_empty():
		GameManager.set_flag(gate_opened_flag, true)
	
	for flag_name: String in flags_to_set_on_pass.keys():
		GameManager.set_flag(flag_name, flags_to_set_on_pass[flag_name])
	
	_do_transition()


func _do_transition() -> void:
	if target_room_id.is_empty():
		print("[GateTrigger] 目标房间未设置")
		return
	
	await RoomManager.change_room(target_room_id, target_spawn_point)
	
	if not area_banner_text.is_empty():
		_show_area_banner()


func _show_area_banner() -> void:
	var banner := get_tree().get_first_node_in_group("area_banner")
	if banner and banner.has_method("show_banner"):
		banner.show_banner(area_banner_text)
	else:
		print("[GateTrigger] 区域横幅: %s" % area_banner_text)


func _set_opened_state_instant() -> void:
	_is_opened = true
	if gate_sprite and gate_sprite.sprite_frames and gate_sprite.sprite_frames.has_animation("open"):
		var frame_count := gate_sprite.sprite_frames.get_frame_count("open")
		if frame_count > 0:
			gate_sprite.animation = "open"
			gate_sprite.frame = frame_count - 1
			gate_sprite.stop()
