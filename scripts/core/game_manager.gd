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
	"recognition": 0,
	"skills": ["deep_echo"]
}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func change_state(new_state: GameState) -> void:
	if current_state != new_state:
		current_state = new_state
		state_changed.emit(new_state)


func start_combat(enemy_data: Dictionary) -> void:
	change_state(GameState.COMBAT)
	TurnManager.start_combat(player_data.duplicate(true), enemy_data)


func end_combat(victory: bool, recognition_gained: int) -> void:
	if victory and recognition_gained > 0:
		player_data.recognition += recognition_gained
		recognition_earned.emit("Enemy", recognition_gained)
	change_state(GameState.EXPLORATION)


func add_overload(amount: int) -> void:
	player_data.overload = mini(player_data.overload + amount, player_data.max_overload)


func reset_overload() -> void:
	player_data.overload = 0


func heal_player(amount: int) -> void:
	player_data.hp = mini(player_data.hp + amount, player_data.max_hp)


func damage_player(amount: int) -> void:
	player_data.hp = maxi(player_data.hp - amount, 0)


func is_player_alive() -> bool:
	return player_data.hp > 0
