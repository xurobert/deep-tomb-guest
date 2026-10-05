extends Node
## TurnManager autoload - handles turn-based combat flow

signal combat_started
signal combat_ended(victory: bool)
signal turn_started(is_player_turn: bool)
signal turn_ended
signal action_performed(actor: String, action: String, target: String, damage: int, effectiveness: String)
signal overload_changed(current: int, maximum: int)
signal resonance_changed(current: int, maximum: int)
signal skill_used(skill_id: String)
signal skill_blocked(skill_id: String, reason: String)
signal enemy_weakness_revealed(weakness_element: String)
signal enemy_phase_changed(phase: int)
signal enemy_telegraph(message: String)
signal guardian_recognition_check(passed: bool, message: String)
signal combat_result(result: String, recognition: int)

enum Effectiveness { NEUTRAL, ADVANTAGE, DISADVANTAGE }
enum CombatResult { WIN, LOSE, RECOGNIZED }

var is_in_combat: bool = false
var is_player_turn: bool = true
var combat_active: bool = false
var action_locked: bool = false

var player: Dictionary = {}
var enemy: Dictionary = {}

var skills_data: Dictionary = {}
var elements_data: Dictionary = {}
var skill_cooldowns: Dictionary = {}

var enemy_rotation_index: int = 0
var current_phase: int = 0
var is_charging: bool = false
var recognition_window_checked: bool = false

var combat_stats: Dictionary = {
	"insight_used": false,
	"weakness_hits": 0,
	"overloaded": false
}


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
	player["resonance"] = int(player.get("resonance", 100))
	player["max_resonance"] = int(player.get("max_resonance", 100))
	enemy["hp"] = int(enemy.get("hp", 30))
	enemy["max_hp"] = int(enemy.get("max_hp", 30))
	enemy["recognition_value"] = int(enemy.get("recognition_value", 10))
	
	skill_cooldowns.clear()
	enemy_rotation_index = 0
	current_phase = 0
	is_charging = false
	recognition_window_checked = false
	
	combat_stats = {
		"insight_used": false,
		"weakness_hits": 0,
		"overloaded": false
	}
	
	_apply_phase_data(0)

	is_in_combat = true
	combat_active = true
	is_player_turn = true
	action_locked = false
	combat_started.emit()
	turn_started.emit(true)


func end_combat(victory: bool, result_type: String = "") -> void:
	var recognition: int = 0
	var actual_result := result_type
	
	if victory:
		if result_type == "recognized":
			var rule: Dictionary = _get_recognition_rule()
			recognition = int(rule.get("recognition_bonus", 30))
			actual_result = "recognized"
		else:
			recognition = int(enemy.get("recognition_value", 10))
			actual_result = "win"
	else:
		actual_result = "lose"

	var enemy_name: String = str(enemy.get("name", "敌人"))
	var is_guardian: bool = enemy.get("is_guardian", false)
	
	is_in_combat = false
	combat_active = false
	action_locked = false
	is_player_turn = false
	
	combat_result.emit(actual_result, recognition)
	combat_ended.emit(victory)
	GameManager.end_combat(victory, recognition, enemy_name, actual_result, is_guardian)


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


func _get_phases() -> Array:
	var phases: Variant = enemy.get("phases", [])
	if typeof(phases) == TYPE_ARRAY:
		return phases
	return []


func _get_current_phase_data() -> Dictionary:
	var phases := _get_phases()
	if phases.size() > current_phase:
		var phase_data: Variant = phases[current_phase]
		if typeof(phase_data) == TYPE_DICTIONARY:
			return phase_data
	return {}


func _apply_phase_data(phase_index: int) -> void:
	var phases := _get_phases()
	if phases.size() <= phase_index:
		return
	
	var phase_data: Variant = phases[phase_index]
	if typeof(phase_data) != TYPE_DICTIONARY:
		return
	
	var pd: Dictionary = phase_data
	if pd.has("element"):
		enemy["element"] = str(pd.get("element", ""))
	if pd.has("attack"):
		enemy["attack"] = int(pd.get("attack", enemy.get("attack", 10)))
	if pd.has("sprite"):
		enemy["sprite"] = str(pd.get("sprite", ""))
	if pd.has("rotation"):
		enemy["rotation"] = pd.get("rotation")


func _check_phase_transition() -> bool:
	var phases := _get_phases()
	if phases.size() <= current_phase + 1:
		return false
	
	var next_phase_data: Variant = phases[current_phase + 1]
	if typeof(next_phase_data) != TYPE_DICTIONARY:
		return false
	
	var npd: Dictionary = next_phase_data
	if not npd.has("hp_ratio_trigger"):
		return false
	
	var trigger_ratio: float = float(npd.get("hp_ratio_trigger", 0.5))
	var current_hp := int(enemy.get("hp", 0))
	var max_hp := int(enemy.get("max_hp", 100))
	
	if current_hp > 0 and current_hp <= int(float(max_hp) * trigger_ratio):
		return true
	return false


func _transition_to_next_phase() -> void:
	current_phase += 1
	enemy_rotation_index = 0
	
	var was_charging := is_charging
	is_charging = false
	
	_apply_phase_data(current_phase)
	
	enemy_phase_changed.emit(current_phase)


func _get_recognition_rule() -> Dictionary:
	var rule: Variant = enemy.get("recognition_rule", {})
	if typeof(rule) == TYPE_DICTIONARY:
		return rule
	return {}


func _check_recognition_window() -> bool:
	var rule := _get_recognition_rule()
	if rule.is_empty():
		return false
	
	var window_ratio: float = float(rule.get("hp_ratio_window", 0.3))
	var current_hp := int(enemy.get("hp", 0))
	var max_hp := int(enemy.get("max_hp", 100))
	
	return current_hp > 0 and current_hp <= int(float(max_hp) * window_ratio)


func _check_recognition_conditions() -> bool:
	var rule := _get_recognition_rule()
	if rule.is_empty():
		return false
	
	if rule.get("require_insight", false) and not combat_stats["insight_used"]:
		return false
	
	var min_hits: int = int(rule.get("min_weakness_hits", 0))
	if combat_stats["weakness_hits"] < min_hits:
		return false
	
	if rule.get("forbid_overload", false) and combat_stats["overloaded"]:
		return false
	
	return true


func _get_current_rotation() -> Array:
	var rotation: Variant = enemy.get("rotation", [])
	if typeof(rotation) == TYPE_ARRAY:
		return rotation
	return []


func _get_enemy_move(move_id: String) -> Dictionary:
	var moves: Variant = enemy.get("moves", {})
	if typeof(moves) == TYPE_DICTIONARY:
		var move: Variant = moves.get(move_id, {})
		if typeof(move) == TYPE_DICTIONARY:
			return move
	return {}


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


func get_skill_resonance_cost(skill_id: String) -> int:
	var skill := get_skill(skill_id)
	return int(skill.get("resonance_cost", 0))


func get_player_resonance() -> int:
	return int(player.get("resonance", 0))


func get_player_max_resonance() -> int:
	return int(player.get("max_resonance", 100))


func has_enough_resonance(skill_id: String) -> bool:
	var cost := get_skill_resonance_cost(skill_id)
	if cost <= 0:
		return true
	return get_player_resonance() >= cost


func can_use_skill(skill_id: String) -> bool:
	var resolved_id := _resolve_skill_alias(skill_id)
	if is_skill_on_cooldown(resolved_id):
		return false
	if not has_enough_resonance(resolved_id):
		return false
	return true


func consume_resonance(amount: int) -> void:
	var current := get_player_resonance()
	var new_val := maxi(current - amount, 0)
	player["resonance"] = new_val
	resonance_changed.emit(new_val, get_player_max_resonance())


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
	
	var resonance_cost: int = int(skill.get("resonance_cost", 0))
	if resonance_cost > 0 and get_player_resonance() < resonance_cost:
		skill_blocked.emit(resolved_id, "共鸣不足")
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
	
	if resonance_cost > 0:
		consume_resonance(resonance_cost)
	
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
	
	if effectiveness == "advantage":
		combat_stats["weakness_hits"] = int(combat_stats.get("weakness_hits", 0)) + 1
	
	if overload_cost > 0:
		var new_overload: int = mini(int(player.get("overload", 0)) + overload_cost, int(player.get("max_overload", 100)))
		player["overload"] = new_overload
		GameManager.add_overload(overload_cost)
		overload_changed.emit(new_overload, int(player.get("max_overload", 100)))
		
		if new_overload >= int(player.get("max_overload", 100)):
			combat_stats["overloaded"] = true
	
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
	
	combat_stats["insight_used"] = true
	
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

	var rotation := _get_current_rotation()
	var damage: int
	var action_name: String
	
	if rotation.is_empty():
		damage = randi_range(5, 12)
		action_name = "攻击"
	else:
		var move_id: String = rotation[enemy_rotation_index % rotation.size()]
		var move := _get_enemy_move(move_id)
		
		if move.is_empty():
			damage = randi_range(5, 12)
			action_name = "攻击"
		else:
			action_name = str(move.get("name", move_id))
			var damage_min: int = int(move.get("damage_min", 5))
			var damage_max: int = int(move.get("damage_max", damage_min))
			
			if damage_min == damage_max:
				damage = damage_min
			else:
				damage = randi_range(damage_min, damage_max)
			
			var telegraph_msg: String = str(move.get("telegraph", ""))
			if not telegraph_msg.is_empty():
				is_charging = true
				enemy_telegraph.emit(telegraph_msg)
		
		enemy_rotation_index = (enemy_rotation_index + 1) % rotation.size()
	
	if damage > 0:
		player["hp"] = int(player.get("hp", 0)) - damage
		GameManager.damage_player(damage)
	
	action_performed.emit("Enemy", action_name, "Player", damage, "neutral")

	await _check_combat_end()
	if combat_active:
		is_player_turn = true
		action_locked = false
		turn_started.emit(true)


func _check_combat_end() -> void:
	var is_guardian: bool = enemy.get("is_guardian", false)
	
	if _check_phase_transition():
		_transition_to_next_phase()
		return
	
	if is_guardian and not recognition_window_checked and _check_recognition_window():
		recognition_window_checked = true
		var passed := _check_recognition_conditions()
		
		if passed:
			var msg: String = str(enemy.get("recognition_message", ""))
			guardian_recognition_check.emit(true, msg)
			combat_active = false
			await get_tree().create_timer(0.5).timeout
			end_combat(true, "recognized")
			return
		else:
			var msg: String = str(enemy.get("rejection_message", ""))
			guardian_recognition_check.emit(false, msg)
	
	if int(enemy.get("hp", 0)) <= 0:
		combat_active = false
		await get_tree().create_timer(0.5).timeout
		end_combat(true, "win")
	elif int(player.get("hp", 0)) <= 0:
		combat_active = false
		await get_tree().create_timer(0.5).timeout
		end_combat(false, "lose")


func get_player_hp() -> int:
	return int(player.get("hp", 0))


func get_enemy_hp() -> int:
	return int(enemy.get("hp", 0))


func get_enemy_sprite_path() -> String:
	return str(enemy.get("sprite", ""))


func get_current_phase() -> int:
	return current_phase


func get_combat_stats() -> Dictionary:
	return combat_stats.duplicate()


func is_enemy_guardian() -> bool:
	return enemy.get("is_guardian", false)


func is_enemy_elite() -> bool:
	return enemy.get("is_elite", false)
