extends Node
## GameManager autoload - handles global game state and scene transitions

signal state_changed(new_state: GameState)
signal recognition_earned(entity_name: String, amount: int)

enum GameState { EXPLORATION, COMBAT, MENU, DIALOGUE, SAVING }

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


func end_combat(victory: bool, recognition_gained: int, enemy_name: String = "敌人") -> void:
	if victory and recognition_gained > 0:
		player_data["recognition"] = int(player_data.get("recognition", 0)) + recognition_gained
		recognition_earned.emit(enemy_name, recognition_gained)
	# Keep combat HP/overload on the exploration sheet
	player_data["hp"] = TurnManager.get_player_hp() if TurnManager.player else int(player_data.get("hp", 100))
	player_data["overload"] = int(TurnManager.player.get("overload", player_data.get("overload", 0))) if TurnManager.player else int(player_data.get("overload", 0))
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


func _try_load_save() -> void:
	if SaveManager.has_save():
		SaveManager.load_game()
		print("[GameManager] 已加载存档")
