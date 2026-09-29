extends SceneTree
## Headless smoke: 测试五技能 + 三属性克制 + 洞察揭示弱点 + 冷却机制
## Run: godot --headless --path . -s res://scripts/tests/vs_combat_smoke.gd

func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	await process_frame
	await process_frame

	var TM: Node = root.get_node("TurnManager")
	var GM: Node = root.get_node("GameManager")
	var ok := true
	var errors: PackedStringArray = []

	if TM.skills_data.is_empty():
		ok = false
		errors.append("skills_data empty")
	
	if TM.elements_data.is_empty():
		ok = false
		errors.append("elements_data empty")

	# ========== 测试 1: 属性克制倍率 ==========
	print("测试属性克制倍率...")
	
	var eff_adv: int = TM.calculate_effectiveness("arcane", "shadow")
	if eff_adv != TM.Effectiveness.ADVANTAGE:
		ok = false
		errors.append("arcane vs shadow should be ADVANTAGE")
	
	var mult_adv: float = TM.get_damage_multiplier(TM.Effectiveness.ADVANTAGE)
	if absf(mult_adv - 1.5) > 0.01:
		ok = false
		errors.append("advantage multiplier should be 1.5, got %f" % mult_adv)
	
	var eff_dis: int = TM.calculate_effectiveness("physical", "shadow")
	if eff_dis != TM.Effectiveness.DISADVANTAGE:
		ok = false
		errors.append("physical vs shadow should be DISADVANTAGE")
	
	var mult_dis: float = TM.get_damage_multiplier(TM.Effectiveness.DISADVANTAGE)
	if absf(mult_dis - 0.75) > 0.01:
		ok = false
		errors.append("disadvantage multiplier should be 0.75, got %f" % mult_dis)
	
	var eff_neu: int = TM.calculate_effectiveness("none", "shadow")
	if eff_neu != TM.Effectiveness.NEUTRAL:
		ok = false
		errors.append("none vs shadow should be NEUTRAL (insight skill)")
	
	var mult_neu: float = TM.get_damage_multiplier(TM.Effectiveness.NEUTRAL)
	if absf(mult_neu - 1.0) > 0.01:
		ok = false
		errors.append("neutral multiplier should be 1.0, got %f" % mult_neu)
	
	var eff_self: int = TM.calculate_effectiveness("arcane", "arcane")
	if eff_self != TM.Effectiveness.NEUTRAL:
		ok = false
		errors.append("arcane vs arcane should be NEUTRAL")
	
	var result_adv: Dictionary = TM.apply_element_multiplier(10, "arcane", "shadow")
	if result_adv["damage"] != 15:
		ok = false
		errors.append("10 * 1.5 should be 15, got %d" % result_adv["damage"])
	if result_adv["effectiveness"] != "advantage":
		ok = false
		errors.append("effectiveness should be 'advantage'")
	
	var result_dis: Dictionary = TM.apply_element_multiplier(10, "physical", "shadow")
	if result_dis["damage"] != 7:
		ok = false
		errors.append("10 * 0.75 should be 7, got %d" % result_dis["damage"])
	if result_dis["effectiveness"] != "disadvantage":
		ok = false
		errors.append("effectiveness should be 'disadvantage'")

	# ========== 测试 2: 弱点推导 ==========
	print("测试弱点推导...")
	
	var weakness_shadow: String = TM.get_weakness("shadow")
	if weakness_shadow != "arcane":
		ok = false
		errors.append("shadow weakness should be arcane, got '%s'" % weakness_shadow)
	
	var weakness_arcane: String = TM.get_weakness("arcane")
	if weakness_arcane != "physical":
		ok = false
		errors.append("arcane weakness should be physical, got '%s'" % weakness_arcane)
	
	var weakness_physical: String = TM.get_weakness("physical")
	if weakness_physical != "shadow":
		ok = false
		errors.append("physical weakness should be shadow, got '%s'" % weakness_physical)

	# ========== 测试 3: 技能别名兼容 ==========
	print("测试技能别名...")
	
	var resolved_deep: String = TM._resolve_skill_alias("deep_echo")
	if resolved_deep != "deep_echo_pulse":
		ok = false
		errors.append("deep_echo should resolve to deep_echo_pulse")
	
	var resolved_basic: String = TM._resolve_skill_alias("basic_attack")
	if resolved_basic != "attack":
		ok = false
		errors.append("basic_attack should resolve to attack")

	# ========== 测试 4: 战斗流程（含克制伤害 + 洞察 + 冷却） ==========
	print("测试战斗流程...")
	
	var enemy := {
		"id": "tomb_shade",
		"name": "墓穴阴魂",
		"hp": 100,
		"max_hp": 100,
		"attack": 8,
		"defense": 2,
		"recognition_value": 15,
		"element": "shadow"
	}

	var recog_got := {"amount": 0, "name": ""}
	GM.recognition_earned.connect(func(entity_name: String, amount: int) -> void:
		recog_got["amount"] = amount
		recog_got["name"] = entity_name
	)
	
	var weakness_revealed := {"element": ""}
	TM.enemy_weakness_revealed.connect(func(weakness_element: String) -> void:
		weakness_revealed["element"] = weakness_element
	)
	
	var action_log: Array[Dictionary] = []
	TM.action_performed.connect(func(actor: String, action: String, target: String, damage: int, effectiveness: String) -> void:
		action_log.append({"actor": actor, "action": action, "target": target, "damage": damage, "effectiveness": effectiveness})
	)
	
	var blocked_skills: Array[Dictionary] = []
	TM.skill_blocked.connect(func(skill_id: String, reason: String) -> void:
		blocked_skills.append({"skill_id": skill_id, "reason": reason})
	)

	GM.player_data["overload"] = 0
	GM.player_data["resonance"] = 100
	GM.player_data["max_resonance"] = 100
	GM.start_combat(enemy)
	await process_frame

	if not TM.is_in_combat:
		ok = false
		errors.append("combat did not start")

	# 测试洞察：不造成伤害，揭示弱点
	print("测试洞察...")
	TM.perform_skill("insight")
	await create_timer(1.2).timeout
	
	if weakness_revealed["element"] != "arcane":
		ok = false
		errors.append("insight should reveal arcane as weakness, got '%s'" % weakness_revealed["element"])
	
	var insight_action: Dictionary = {}
	for a: Dictionary in action_log:
		if a["action"] == "洞察":
			insight_action = a
			break
	if insight_action.is_empty():
		ok = false
		errors.append("insight action not logged")
	elif insight_action["damage"] != 0:
		ok = false
		errors.append("insight should deal 0 damage, got %d" % insight_action["damage"])

	# 测试斩击冷却
	print("测试斩击冷却...")
	if TM.combat_active and TM.is_player_turn:
		var pre_slash_cd: int = TM.get_skill_cooldown("slash")
		if pre_slash_cd != 0:
			ok = false
			errors.append("slash should not be on cooldown initially")
		
		TM.perform_skill("slash")
		await create_timer(1.2).timeout
		
		var post_slash_cd: int = TM.get_skill_cooldown("slash")
		if post_slash_cd < 1:
			ok = false
			errors.append("slash should be on cooldown after use, got %d" % post_slash_cd)
	
	# 测试 arcane_bolt（咒弹）打 shadow 敌人（克制）+ 消耗共鸣
	print("测试咒弹克制伤害和共鸣消耗...")
	var pre_resonance: int = TM.get_player_resonance()
	if pre_resonance != 100:
		ok = false
		errors.append("initial resonance should be 100, got %d" % pre_resonance)
	
	var pre_overload := int(GM.player_data.get("overload", 0))
	if TM.combat_active and TM.is_player_turn:
		TM.perform_skill("arcane_bolt")
		await create_timer(1.2).timeout
	
	var post_bolt_resonance: int = TM.get_player_resonance()
	if post_bolt_resonance != 80:
		ok = false
		errors.append("after arcane_bolt resonance should be 80 (100 - 20), got %d" % post_bolt_resonance)
	
	var arcane_action: Dictionary = {}
	for a: Dictionary in action_log:
		if a["action"] == "咒弹":
			arcane_action = a
			break
	if arcane_action.is_empty():
		ok = false
		errors.append("arcane_bolt action not logged")
	elif arcane_action["effectiveness"] != "advantage":
		ok = false
		errors.append("arcane vs shadow should be advantage, got '%s'" % arcane_action["effectiveness"])
	elif arcane_action["damage"] != 27:
		ok = false
		errors.append("arcane_bolt (18 * 1.5 = 27) damage expected, got %d" % arcane_action["damage"])

	# 测试 attack 打 shadow 敌人（被克）
	print("测试被克伤害...")
	if TM.combat_active and TM.is_player_turn:
		TM.perform_skill("attack")
		await create_timer(1.2).timeout
	
	var attack_actions: Array[Dictionary] = []
	for a: Dictionary in action_log:
		if a["action"] == "攻击" and a["actor"] == "Player":
			attack_actions.append(a)
	if attack_actions.is_empty():
		ok = false
		errors.append("attack action not logged")
	else:
		var last_attack := attack_actions[attack_actions.size() - 1]
		if last_attack["effectiveness"] != "disadvantage":
			ok = false
			errors.append("physical vs shadow should be disadvantage, got '%s'" % last_attack["effectiveness"])

	# 测试只有 arcane_bolt 和 deep_echo_pulse 增加失控
	print("测试失控增长...")
	var mid_overload := int(GM.player_data.get("overload", 0))
	if mid_overload != 15:
		ok = false
		errors.append("only arcane_bolt should add 15 overload so far, got %d" % mid_overload)

	if TM.combat_active and TM.is_player_turn:
		TM.perform_skill("deep_echo_pulse")
		await create_timer(1.2).timeout
	
	var post_deep_overload := int(GM.player_data.get("overload", 0))
	if post_deep_overload != 45:
		ok = false
		errors.append("after deep_echo_pulse overload should be 45, got %d" % post_deep_overload)

	# 测试共鸣不足时咒弹不可用
	print("测试共鸣不足时咒弹不可用...")
	if TM.combat_active and TM.is_player_turn:
		TM.player["resonance"] = 10
		blocked_skills.clear()
		
		TM.perform_skill("arcane_bolt")
		await create_timer(0.5).timeout
		
		var bolt_blocked := false
		for b: Dictionary in blocked_skills:
			if b["skill_id"] == "arcane_bolt":
				bolt_blocked = true
				break
		if not bolt_blocked:
			ok = false
			errors.append("arcane_bolt should be blocked when resonance < 20")
		
		if not TM.has_enough_resonance("arcane_bolt"):
			pass
		else:
			ok = false
			errors.append("has_enough_resonance should return false when resonance=10 for arcane_bolt(cost=20)")
		
		TM.player["resonance"] = 100

	# 继续战斗直到结束
	var guard := 0
	while TM.combat_active and guard < 15:
		guard += 1
		if TM.is_player_turn and not TM.action_locked:
			TM.perform_skill("arcane_bolt")
		await create_timer(1.0).timeout

	await create_timer(0.8).timeout

	if TM.is_in_combat:
		ok = false
		errors.append("combat still active after loop")

	if int(GM.player_data.get("recognition", 0)) <= 0 and int(recog_got["amount"]) <= 0:
		ok = false
		errors.append("recognition not granted")

	if GM.current_state != GM.GameState.EXPLORATION:
		ok = false
		errors.append("not back to exploration")

	print("smoke_stats overload=", GM.player_data.get("overload", 0), " recognition=", GM.player_data.get("recognition", 0), " entity=", recog_got["name"])

	if ok:
		print("VS_COMBAT_SMOKE_OK")
		quit(0)
	else:
		print("VS_COMBAT_SMOKE_FAIL: ", ", ".join(errors))
		quit(1)
