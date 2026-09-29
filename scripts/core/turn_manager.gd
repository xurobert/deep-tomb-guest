extends Node
## TurnManager autoload - handles turn-based combat flow

signal combat_started
signal combat_ended(victory: bool)
signal turn_started(is_player_turn: bool)
signal turn_ended
signal action_performed(actor: String, action: String, target: String, damage: int, effectiveness: String)
signal overload_changed(current: int, maximum: int)
signal skill_used(skill_id: String)
signal enemy_weakness_revealed(weakness_element: String)

enum Effectiveness { NEUTRAL, ADVANTAGE, DISADVANTAGE }

var is_in_combat: bool = false
var is_player_turn: bool = true
var combat_active: bool = false
var action_locked: bool = false

var player: Dictionary = {}
var enemy: Dictionary = {}

var skills_data: Dictionary = {}
var elements_data: Dictionary = {}
var skill_cooldowns: Dictionary = {}


func _ready() -> void:
	_load_skills_data()
	_load_elements_data()


func _load_skills_data() -> void:
	var file := FileAccess.open("res://data/skills.json", FileAccess.READ)
	if file:
		var json := JSON.new()
		if json.parse(file.get_as_text()) == OK and typeof(json.data) == TYPE_DICTIONARY:
			skills_data = json.data
		file.close()


func _load_elements_data() -> void:
	var file := FileAccess.open("res://data/elements.json", FileAccess.READ)
	if file:
		var json := JSON.new()
		if json.parse(file.get_as_text()) == OK and typeof(json.data) == TYPE_DICTIONARY:
			elements_data = json.data
		file.close()


func _resolve_skill_alias(skill_id: String) -> String:
	var aliases: Variant = skills_data.get("_aliases", {})
	if typeof(aliases) == TYPE_DICTIONARY:
		var resolved: Variant = aliases.get(skill_id, skill_id)
		if typeof(resolved) == TYPE_STRING:
			return resolved
	return skill_id


func get_skill(skill_id: String) -> Dictionary:
	var resolved_id := _resolve_skill_alias(skill_id)
	var raw: Variant = skills_data.get(resolved_id, {})
	if typeof(raw) == TYPE_DICTIONARY:
		return raw
	return {}


func start_combat(player_data: Dictionary, enemy_data: Dictionary) -> void:
	player = player_data.duplicate(true)
	enemy = enemy_data.duplicate(true)
	player["hp"] = int(player.get("hp", 100))
	player["max_hp"] = int(player.get("max_hp", 100))
	player["overload"] = int(player.get("overload", 0))
	player["max_overload"] = int(player.get("max_overload", 100))
	enemy["hp"] = int(enemy.get("hp", 30))
	enemy["max_hp"] = int(enemy.get("max_hp", 30))
	enemy["recognition_value"] = int(enemy.get("recognition_value", 10))
	
	skill_cooldowns.clear()

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


func get_element_data(element_id: String) -> Dictionary:
	var raw: Variant = elements_data.get(element_id, {})
	if typeof(raw) == TYPE_DICTIONARY:
		return raw
	return {}


func get_weakness(defender_element: String) -> String:
	for elem_id: String in elements_data.keys():
		if elem_id == "multipliers" or elem_id.begins_with("_"):
			continue
		var elem: Dictionary = get_element_data(elem_id)
		if elem.get("beats", "") == defender_element:
			return elem_id
	return ""


func calculate_effectiveness(attack_element: String, defender_element: String) -> Effectiveness:
	if attack_element == "none" or attack_element.is_empty():
		return Effectiveness.NEUTRAL
	if defender_element.is_empty():
		return Effectiveness.NEUTRAL
	
	var attacker_elem := get_element_data(attack_element)
	var defender_elem := get_element_data(defender_element)
	
	if attacker_elem.get("beats", "") == defender_element:
		return Effectiveness.ADVANTAGE
	elif defender_elem.get("beats", "") == attack_element:
		return Effectiveness.DISADVANTAGE
	
	return Effectiveness.NEUTRAL


func get_damage_multiplier(effectiveness: Effectiveness) -> float:
	var multipliers: Variant = elements_data.get("multipliers", {})
	if typeof(multipliers) != TYPE_DICTIONARY:
		return 1.0
	
	match effectiveness:
		Effectiveness.ADVANTAGE:
			return float(multipliers.get("advantage", 1.5))
		Effectiveness.DISADVANTAGE:
			return float(multipliers.get("disadvantage", 0.75))
		_:
			return float(multipliers.get("neutral", 1.0))


func apply_element_multiplier(base_damage: int, attack_element: String, defender_element: String) -> Dictionary:
	var effectiveness := calculate_effectiveness(attack_element, defender_element)
	var multiplier := get_damage_multiplier(effectiveness)
	var final_damage := maxi(int(float(base_damage) * multiplier), 1)
	
	var eff_str: String
	match effectiveness:
		Effectiveness.ADVANTAGE:
			eff_str = "advantage"
		Effectiveness.DISADVANTAGE:
			eff_str = "disadvantage"
		_:
			eff_str = "neutral"
	
	return {"damage": final_damage, "effectiveness": eff_str}


func get_skill_cooldown(skill_id: String) -> int:
	return int(skill_cooldowns.get(skill_id, 0))


func is_skill_on_cooldown(skill_id: String) -> bool:
	return get_skill_cooldown(skill_id) > 0


func _tick_cooldowns() -> void:
	for skill_id: String in skill_cooldowns.keys():
		var cd: int = int(skill_cooldowns.get(skill_id, 0))
		if cd > 0:
			skill_cooldowns[skill_id] = cd - 1


func perform_attack() -> void:
	perform_skill("attack")


func perform_skill(skill_id: String) -> void:
	if not is_player_turn or not combat_active or action_locked:
		return

	var resolved_id := _resolve_skill_alias(skill_id)
	var skill := get_skill(resolved_id)
	if skill.is_empty():
		return
	
	if is_skill_on_cooldown(resolved_id):
		return

	action_locked = true
	is_player_turn = false

	var skill_name: String = str(skill.get("name", resolved_id))
	var skill_element: String = str(skill.get("element", "none"))
	var overload_cost: int = int(skill.get("overload_cost", 0))
	var cooldown: int = int(skill.get("cooldown", 0))
	
	if resolved_id == "insight":
		_perform_insight(skill_name)
		return
	
	var damage_min: int = int(skill.get("damage_min", int(skill.get("base_damage", 10))))
	var damage_max: int = int(skill.get("damage_max", damage_min))
	var base_damage: int
	if damage_min == damage_max:
		base_damage = damage_min
	else:
		base_damage = randi_range(damage_min, damage_max)
	
	var enemy_element: String = str(enemy.get("element", ""))
	var result := apply_element_multiplier(base_damage, skill_element, enemy_element)
	var final_damage: int = result["damage"]
	var effectiveness: String = result["effectiveness"]
	
	enemy["hp"] = int(enemy.get("hp", 0)) - final_damage
	
	if overload_cost > 0:
		player["overload"] = mini(int(player.get("overload", 0)) + overload_cost, int(player.get("max_overload", 100)))
		GameManager.add_overload(overload_cost)
		overload_changed.emit(int(player["overload"]), int(player.get("max_overload", 100)))
	
	if cooldown > 0:
		skill_cooldowns[resolved_id] = cooldown
	
	skill_used.emit(resolved_id)
	action_performed.emit("Player", skill_name, "Enemy", final_damage, effectiveness)

	await _check_combat_end()
	if combat_active:
		_end_player_turn()


func _perform_insight(skill_name: String) -> void:
	var enemy_element: String = str(enemy.get("element", ""))
	var weakness := get_weakness(enemy_element)
	
	skill_used.emit("insight")
	action_performed.emit("Player", skill_name, "Enemy", 0, "neutral")
	enemy_weakness_revealed.emit(weakness)
	
	await _check_combat_end()
	if combat_active:
		_end_player_turn()


func reveal_enemy_intel() -> void:
	var enemy_element: String = str(enemy.get("element", ""))
	var weakness := get_weakness(enemy_element)
	enemy_weakness_revealed.emit(weakness)


func _end_player_turn() -> void:
	_tick_cooldowns()
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
	action_performed.emit("Enemy", "攻击", "Player", damage, "neutral")

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
