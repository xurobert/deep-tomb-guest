extends Node
## GameManager autoload - handles global game state and scene transitions

signal state_changed(new_state: GameState)
signal recognition_earned(entity_name: String, amount: int)
signal guardian_result(result: String, recognition: int)
signal chapter_complete(chapter: int)
signal combat_defeat

enum GameState { EXPLORATION, COMBAT, MENU, DIALOGUE, SAVING }

var flags: Dictionary = {}

var current_state: GameState = GameState.EXPLORATION
var player_data: Dictionary = {
	"name": "流浪者",
	"hp": 100,
	"max_hp": 100,
	"overload": 0,
	"max_overload": 100,
	"resonance": 100,
	"max_resonance": 100,
	"recognition": 0,
	"skills": ["deep_echo"]
}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("_try_load_save")


func change_state(new_state: GameState) -> void:
	if current_state != new_state:
		current_state = new_state
		state_changed.emit(new_state)


func start_combat(enemy_data: Dictionary) -> void:
	if current_state == GameState.COMBAT or TurnManager.is_in_combat:
		return
	change_state(GameState.COMBAT)
	TurnManager.start_combat(player_data.duplicate(true), enemy_data)


func end_combat(victory: bool, recognition_gained: int, enemy_name: String = "敌人", result_type: String = "", is_guardian: bool = false) -> void:
	if victory and recognition_gained > 0:
		player_data["recognition"] = int(player_data.get("recognition", 0)) + recognition_gained
		recognition_earned.emit(enemy_name, recognition_gained)
	
	player_data["hp"] = TurnManager.get_player_hp() if TurnManager.player else int(player_data.get("hp", 100))
	player_data["overload"] = int(TurnManager.player.get("overload", player_data.get("overload", 0))) if TurnManager.player else int(player_data.get("overload", 0))
	
	if is_guardian:
		flags["guardian_1_result"] = result_type
		if victory:
			flags["guardian_1_defeated"] = true
			flags["chapter_1_complete"] = true
			if result_type == "recognized":
				flags["guardian_1_recognition"] = 2
			else:
				flags["guardian_1_recognition"] = 1
			guardian_result.emit(result_type, recognition_gained)
			chapter_complete.emit(1)
		else:
			combat_defeat.emit()
	elif not victory:
		combat_defeat.emit()
	
	change_state(GameState.EXPLORATION)


func add_overload(amount: int) -> void:
	player_data["overload"] = mini(int(player_data.get("overload", 0)) + amount, int(player_data.get("max_overload", 100)))


func reset_overload() -> void:
	player_data["overload"] = 0


func heal_player(amount: int) -> void:
	player_data["hp"] = mini(int(player_data.get("hp", 0)) + amount, int(player_data.get("max_hp", 100)))


func damage_player(amount: int) -> void:
	player_data["hp"] = maxi(int(player_data.get("hp", 0)) - amount, 0)


func is_player_alive() -> bool:
	return int(player_data.get("hp", 0)) > 0


func restore_full_hp() -> void:
	player_data["hp"] = int(player_data.get("max_hp", 100))


func set_flag(flag_name: String, value: Variant) -> void:
	flags[flag_name] = value


func get_flag(flag_name: String, default_value: Variant = null) -> Variant:
	return flags.get(flag_name, default_value)


func has_flag(flag_name: String) -> bool:
	return flags.has(flag_name) and flags[flag_name]


func show_confirm(message: String, on_confirm: Callable = Callable(), on_cancel: Callable = Callable()) -> void:
	var dialog := get_tree().get_first_node_in_group("confirm_dialog")
	if dialog == null:
		dialog = _find_confirm_dialog()
	if dialog and dialog.has_method("show_confirm"):
		dialog.show_confirm(message, on_confirm, on_cancel)
	else:
		print("[GameManager] ConfirmDialog 未找到，直接执行确认回调")
		if on_confirm.is_valid():
			on_confirm.call()


func _find_confirm_dialog() -> Node:
	var root := get_tree().current_scene
	if root:
		return root.find_child("ConfirmDialog", true, false)
	return null


func _try_load_save() -> void:
	if SaveManager.has_save():
		SaveManager.load_game()
		print("[GameManager] 已加载存档")
