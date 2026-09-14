extends Node
## TurnManager autoload - handles turn-based combat flow

signal combat_started
signal combat_ended(victory: bool)
signal turn_started(is_player_turn: bool)
signal turn_ended
signal action_performed(actor: String, action: String, target: String, damage: int)
signal overload_changed(current: int, maximum: int)
signal skill_used(skill_id: String)

var is_in_combat: bool = false
var is_player_turn: bool = true
var combat_active: bool = false
var action_locked: bool = false

var player: Dictionary = {}
var enemy: Dictionary = {}

var skills_data: Dictionary = {}


func _ready() -> void:
	_load_skills_data()


func _load_skills_data() -> void:
	var file := FileAccess.open("res://data/skills.json", FileAccess.READ)
	if file:
		var json := JSON.new()
		if json.parse(file.get_as_text()) == OK and typeof(json.data) == TYPE_DICTIONARY:
			skills_data = json.data
		file.close()


func start_combat(player_data: Dictionary, enemy_data: Dictionary) -> void:
	player = player_data.duplicate(true)
	enemy = enemy_data.duplicate(true)
	# JSON numbers arrive as float — coerce combat stats to int
	player["hp"] = int(player.get("hp", 100))
	player["max_hp"] = int(player.get("max_hp", 100))
	player["overload"] = int(player.get("overload", 0))
	player["max_overload"] = int(player.get("max_overload", 100))
	enemy["hp"] = int(enemy.get("hp", 30))
	enemy["max_hp"] = int(enemy.get("max_hp", 30))
	enemy["recognition_value"] = int(enemy.get("recognition_value", 10))

	is_in_combat = true
	combat_active = true
	is_player_turn = true
	action_locked = false
	combat_started.emit()
	turn_started.emit(true)


func end_combat(victory: bool) -> void:
	var recognition: int = 0
	if victory:
		recognition = int(enemy.get("recognition_value", 10))

	var enemy_name: String = str(enemy.get("name", "敌人"))
	is_in_combat = false
	combat_active = false
	action_locked = false
	is_player_turn = false
	combat_ended.emit(victory)
	GameManager.end_combat(victory, recognition, enemy_name)


func perform_attack() -> void:
	if not is_player_turn or not combat_active or action_locked:
		return

	action_locked = true
	is_player_turn = false

	var damage: int = randi_range(8, 15)
	enemy["hp"] = int(enemy.get("hp", 0)) - damage
	action_performed.emit("Player", "攻击", "Enemy", damage)

	await _check_combat_end()
	if combat_active:
		_end_player_turn()


func perform_skill(skill_id: String) -> void:
	if not is_player_turn or not combat_active or action_locked:
		return

	var skill: Dictionary = {}
	var raw: Variant = skills_data.get(skill_id, {})
	if typeof(raw) == TYPE_DICTIONARY:
		skill = raw
	if skill.is_empty():
		return

	action_locked = true
	is_player_turn = false

	var damage: int = int(skill.get("base_damage", 20))
	var overload_cost: int = int(skill.get("overload_cost", 25))
	var skill_name: String = str(skill.get("name", skill_id))

	enemy["hp"] = int(enemy.get("hp", 0)) - damage
	player["overload"] = mini(int(player.get("overload", 0)) + overload_cost, int(player.get("max_overload", 100)))
	GameManager.add_overload(overload_cost)

	overload_changed.emit(int(player["overload"]), int(player.get("max_overload", 100)))
	skill_used.emit(skill_id)
	action_performed.emit("Player", skill_name, "Enemy", damage)

	await _check_combat_end()
	if combat_active:
		_end_player_turn()


func _end_player_turn() -> void:
	turn_ended.emit()
	await get_tree().create_timer(0.5).timeout
	if combat_active:
		await _do_enemy_turn()


func _do_enemy_turn() -> void:
	turn_started.emit(false)
	await get_tree().create_timer(0.3).timeout
	if not combat_active:
		return

	var damage: int = randi_range(5, 12)
	player["hp"] = int(player.get("hp", 0)) - damage
	GameManager.damage_player(damage)
	action_performed.emit("Enemy", "攻击", "Player", damage)

	await _check_combat_end()
	if combat_active:
		is_player_turn = true
		action_locked = false
		turn_started.emit(true)


func _check_combat_end() -> void:
	if int(enemy.get("hp", 0)) <= 0:
		combat_active = false
		await get_tree().create_timer(0.5).timeout
		end_combat(true)
	elif int(player.get("hp", 0)) <= 0:
		combat_active = false
		await get_tree().create_timer(0.5).timeout
		end_combat(false)


func get_player_hp() -> int:
	return int(player.get("hp", 0))


func get_enemy_hp() -> int:
	return int(enemy.get("hp", 0))
