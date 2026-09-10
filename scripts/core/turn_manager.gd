extends Node
## TurnManager autoload - handles turn-based combat flow

signal combat_started
signal combat_ended(victory: bool)
signal turn_started(is_player_turn: bool)
signal turn_ended
signal action_performed(actor: String, action: String, target: String, damage: int)
signal overload_changed(current: int, maximum: int)

var is_in_combat: bool = false
var is_player_turn: bool = true
var combat_active: bool = false

var player: Dictionary = {}
var enemy: Dictionary = {}

var skills_data: Dictionary = {}


func _ready() -> void:
	_load_skills_data()


func _load_skills_data() -> void:
	var file := FileAccess.open("res://data/skills.json", FileAccess.READ)
	if file:
		var json := JSON.new()
		if json.parse(file.get_as_text()) == OK:
			skills_data = json.data
		file.close()


func start_combat(player_data: Dictionary, enemy_data: Dictionary) -> void:
	player = player_data
	enemy = enemy_data
	is_in_combat = true
	combat_active = true
	is_player_turn = true
	combat_started.emit()
	turn_started.emit(true)


func end_combat(victory: bool) -> void:
	var recognition := 0
	if victory:
		recognition = enemy.get("recognition_value", 10)
	
	is_in_combat = false
	combat_active = false
	combat_ended.emit(victory)
	GameManager.end_combat(victory, recognition)


func perform_attack() -> void:
	if not is_player_turn or not combat_active:
		return
	
	var damage := randi_range(8, 15)
	enemy.hp -= damage
	action_performed.emit("Player", "Attack", "Enemy", damage)
	
	_check_combat_end()
	if combat_active:
		_end_player_turn()


func perform_skill(skill_id: String) -> void:
	if not is_player_turn or not combat_active:
		return
	
	var skill: Dictionary = skills_data.get(skill_id, {})
	if skill.is_empty():
		return
	
	var damage: int = skill.get("base_damage", 20)
	var overload_cost: int = skill.get("overload_cost", 25)
	
	enemy.hp -= damage
	player.overload += overload_cost
	GameManager.add_overload(overload_cost)
	
	overload_changed.emit(player.overload, player.get("max_overload", 100))
	action_performed.emit("Player", skill.get("name", skill_id), "Enemy", damage)
	
	_check_combat_end()
	if combat_active:
		_end_player_turn()


func _end_player_turn() -> void:
	is_player_turn = false
	turn_ended.emit()
	
	await get_tree().create_timer(0.5).timeout
	
	if combat_active:
		_do_enemy_turn()


func _do_enemy_turn() -> void:
	turn_started.emit(false)
	
	await get_tree().create_timer(0.3).timeout
	
	var damage := randi_range(5, 12)
	player.hp -= damage
	GameManager.damage_player(damage)
	action_performed.emit("Enemy", "Attack", "Player", damage)
	
	_check_combat_end()
	if combat_active:
		is_player_turn = true
		turn_started.emit(true)


func _check_combat_end() -> void:
	if enemy.hp <= 0:
		combat_active = false
		await get_tree().create_timer(0.5).timeout
		end_combat(true)
	elif player.hp <= 0:
		combat_active = false
		await get_tree().create_timer(0.5).timeout
		end_combat(false)


func get_player_hp() -> int:
	return player.get("hp", 0)


func get_enemy_hp() -> int:
	return enemy.get("hp", 0)
