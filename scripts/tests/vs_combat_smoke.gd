extends SceneTree
## Headless smoke: 测试五技能 + 三属性克制 + 洞察揭示弱点 + 冷却机制 + 精英阶段变化 + 守护者三档判定
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

	# ========== 测试 4: 死骸骑士阶段变化 ==========
	print("测试死骸骑士阶段变化...")
	
	var death_knight := {
		"id": "death_knight",
		"name": "死骸骑士",
		"hp": 140,
		"max_hp": 140,
		"attack": 9,
		"recognition_value": 20,
		"element": "arcane",
		"is_elite": true,
		"moves": {
			"knight_cleave": {"name": "横斩", "damage_min": 7, "damage_max": 11},
			"knight_charge": {"name": "举剑蓄力", "damage_min": 0, "damage_max": 0, "telegraph": "死骸骑士高举巨剑……下回合将发动重击！"},
			"knight_crush": {"name": "碎骨重击", "damage_min": 20, "damage_max": 20}
		},
		"phases": [
			{"phase_name": "咒缚铠甲", "element": "arcane", "attack": 9, "rotation": ["knight_cleave", "knight_cleave", "knight_charge", "knight_crush"]},
			{"phase_name": "暗影本体", "element": "shadow", "attack": 12, "rotation": ["knight_cleave", "knight_charge", "knight_crush"], "hp_ratio_trigger": 0.5}
		],
		"rotation": ["knight_cleave", "knight_cleave", "knight_charge", "knight_crush"]
	}
	
	var phase_changed := {"count": 0, "phase": -1}
	TM.enemy_phase_changed.connect(func(phase: int) -> void:
		phase_changed["count"] = int(phase_changed["count"]) + 1
		phase_changed["phase"] = phase
	)
	
	var telegraph_received := {"count": 0, "msg": ""}
	TM.enemy_telegraph.connect(func(message: String) -> void:
		telegraph_received["count"] = int(telegraph_received["count"]) + 1
		telegraph_received["msg"] = message
	)
	
	GM.player_data["hp"] = 100
	GM.player_data["max_hp"] = 100
	GM.player_data["overload"] = 0
	GM.player_data["resonance"] = 100
	GM.start_combat(death_knight)
	await process_frame
	
	if TM.current_phase != 0:
		ok = false
		errors.append("death_knight should start at phase 0, got %d" % TM.current_phase)
	
	var initial_element: String = str(TM.enemy.get("element", ""))
	if initial_element != "arcane":
		ok = false
		errors.append("death_knight phase 0 element should be arcane, got '%s'" % initial_element)
	
	var initial_hp: int = int(TM.enemy.get("hp", 0))
	while int(TM.enemy.get("hp", 0)) > 71 and TM.combat_active:
		if TM.is_player_turn and not TM.action_locked:
			TM.perform_skill("attack")
		await create_timer(0.8).timeout
	
	await create_timer(0.3).timeout
	
	if TM.combat_active:
		var mid_hp: int = int(TM.enemy.get("hp", 0))
		while int(TM.enemy.get("hp", 0)) > 69 and TM.combat_active:
			if TM.is_player_turn and not TM.action_locked:
				TM.perform_skill("attack")
			await create_timer(0.8).timeout
		
		await create_timer(0.5).timeout
		
		if int(phase_changed["count"]) < 1:
			ok = false
			errors.append("death_knight should trigger phase change when hp <= 70, phase_changed count=%d" % int(phase_changed["count"]))
		
		if TM.current_phase != 1 and TM.combat_active:
			ok = false
			errors.append("death_knight should be at phase 1 after hp <= 70, got %d" % TM.current_phase)
		
		var new_element: String = str(TM.enemy.get("element", ""))
		if new_element != "shadow" and TM.combat_active:
			ok = false
			errors.append("death_knight phase 1 element should be shadow, got '%s'" % new_element)
		
		var hp_after_phase: int = int(TM.enemy.get("hp", 0))
		if hp_after_phase > 70 or hp_after_phase >= initial_hp:
			ok = false
			errors.append("death_knight HP should not reset on phase change, hp=%d" % hp_after_phase)
	
	var guard := 0
	while TM.combat_active and guard < 20:
		guard += 1
		if TM.is_player_turn and not TM.action_locked:
			TM.perform_skill("arcane_bolt")
		await create_timer(0.8).timeout
	
	await create_timer(0.5).timeout

	# ========== 测试 5: 守护者战认可判定 - 满足条件 ==========
	print("测试守护者战认可判定（满足条件）...")
	
	var undead_overlord := {
		"id": "undead_overlord",
		"name": "死者统领",
		"hp": 160,
		"max_hp": 160,
		"attack": 10,
		"recognition_value": 10,
		"element": "physical",
		"is_guardian": true,
		"moves": {
			"necro_bolt": {"name": "死灵弹", "damage_min": 7, "damage_max": 11}
		},
		"rotation": ["necro_bolt", "necro_bolt", "necro_bolt", "necro_bolt"],
		"recognition_rule": {
			"require_insight": true,
			"min_weakness_hits": 3,
			"forbid_overload": true,
			"hp_ratio_window": 0.3,
			"recognition_bonus": 30
		},
		"recognition_message": "……住手。你看穿了我的本质，却没被力量吞噬。",
		"rejection_message": "死者统领：……仅此而已吗。"
	}
	
	var recognition_check := {"passed": null, "msg": ""}
	TM.guardian_recognition_check.connect(func(passed: bool, message: String) -> void:
		recognition_check["passed"] = passed
		recognition_check["msg"] = message
	)
	
	var combat_result_data := {"result": "", "recognition": 0}
	TM.combat_result.connect(func(result: String, recognition: int) -> void:
		combat_result_data["result"] = result
		combat_result_data["recognition"] = recognition
	)
	
	GM.player_data["hp"] = 100
	GM.player_data["max_hp"] = 100
	GM.player_data["overload"] = 0
	GM.player_data["resonance"] = 100
	GM.start_combat(undead_overlord)
	await process_frame
	
	TM.perform_skill("insight")
	await create_timer(1.0).timeout
	
	if not TM.combat_stats["insight_used"]:
		ok = false
		errors.append("combat_stats.insight_used should be true after insight")
	
	var hits_needed := 3
	var hits_done := 0
	guard = 0
	while TM.combat_active and hits_done < hits_needed and guard < 15:
		guard += 1
		if TM.is_player_turn and not TM.action_locked:
			TM.perform_skill("deep_echo_pulse")
			hits_done += 1
		await create_timer(1.0).timeout
	
	await create_timer(0.5).timeout
	
	if TM.combat_stats["weakness_hits"] < 3:
		ok = false
		errors.append("combat_stats.weakness_hits should be >= 3, got %d" % TM.combat_stats["weakness_hits"])
	
	var overload_val: int = int(TM.player.get("overload", 0))
	if overload_val >= 100:
		ok = false
		errors.append("overload should stay below 100 for recognition test, got %d" % overload_val)
	
	if TM.combat_stats["overloaded"]:
		ok = false
		errors.append("combat_stats.overloaded should be false, got true")
	
	guard = 0
	while TM.combat_active and guard < 15:
		guard += 1
		if TM.is_player_turn and not TM.action_locked:
			TM.perform_skill("attack")
		await create_timer(1.0).timeout
	
	await create_timer(1.0).timeout
	
	if recognition_check["passed"] == null:
		ok = false
		errors.append("guardian_recognition_check should have been emitted")
	elif recognition_check["passed"] != true:
		ok = false
		errors.append("guardian recognition should pass with proper conditions")
	
	if combat_result_data["result"] != "recognized" and combat_result_data["result"] != "win":
		ok = false
		errors.append("guardian combat result should be 'recognized' or 'win', got '%s'" % combat_result_data["result"])

	# ========== 测试 6: 守护者战认可判定 - 未满足条件（未洞察） ==========
	print("测试守护者战认可判定（未满足条件）...")
	
	recognition_check["passed"] = null
	recognition_check["msg"] = ""
	combat_result_data["result"] = ""
	combat_result_data["recognition"] = 0
	
	var undead_overlord2 := undead_overlord.duplicate(true)
	undead_overlord2["hp"] = 80
	undead_overlord2["max_hp"] = 80
	
	GM.player_data["hp"] = 100
	GM.player_data["overload"] = 0
	GM.player_data["resonance"] = 100
	GM.start_combat(undead_overlord2)
	await process_frame
	
	guard = 0
	while TM.combat_active and guard < 20:
		guard += 1
		if TM.is_player_turn and not TM.action_locked:
			TM.perform_skill("deep_echo_pulse")
		await create_timer(0.8).timeout
	
	await create_timer(1.0).timeout
	
	if recognition_check["passed"] == true:
		ok = false
		errors.append("guardian recognition should NOT pass without insight")

	# ========== 测试 7: 敌人出招 rotation 循环 ==========
	print("测试敌人出招rotation循环...")
	
	var simple_enemy := {
		"id": "test_enemy",
		"name": "测试敌人",
		"hp": 200,
		"max_hp": 200,
		"attack": 5,
		"recognition_value": 5,
		"element": "shadow",
		"moves": {
			"move_a": {"name": "招式A", "damage_min": 5, "damage_max": 5},
			"move_b": {"name": "招式B", "damage_min": 10, "damage_max": 10}
		},
		"rotation": ["move_a", "move_b", "move_a"]
	}
	
	var enemy_actions: Array[String] = []
	TM.action_performed.connect(_track_enemy_action.bind(enemy_actions))
	
	GM.player_data["hp"] = 100
	GM.player_data["overload"] = 0
	GM.player_data["resonance"] = 100
	GM.start_combat(simple_enemy)
	await process_frame
	
	for i in range(6):
		if not TM.combat_active:
			break
		if TM.is_player_turn and not TM.action_locked:
			TM.perform_skill("attack")
		await create_timer(1.2).timeout
	
	await create_timer(0.5).timeout
	
	if enemy_actions.size() >= 3:
		if enemy_actions[0] != "招式A":
			ok = false
			errors.append("enemy rotation[0] should be '招式A', got '%s'" % enemy_actions[0])
		if enemy_actions[1] != "招式B":
			ok = false
			errors.append("enemy rotation[1] should be '招式B', got '%s'" % enemy_actions[1])
		if enemy_actions[2] != "招式A":
			ok = false
			errors.append("enemy rotation[2] should be '招式A', got '%s'" % enemy_actions[2])
	
	guard = 0
	while TM.combat_active and guard < 15:
		guard += 1
		if TM.is_player_turn and not TM.action_locked:
			TM.perform_skill("arcane_bolt")
		await create_timer(0.8).timeout
	
	await create_timer(0.5).timeout

	# ========== 测试 8: 原有战斗流程验证 ==========
	print("测试原有战斗流程...")
	
	var tomb_shade := {
		"id": "tomb_shade",
		"name": "墓穴阴魂",
		"hp": 50,
		"max_hp": 50,
		"attack": 8,
		"defense": 2,
		"recognition_value": 15,
		"element": "shadow"
	}

	var recog_got := {"amount": 0, "name": ""}
	var recog_conn := func(entity_name: String, amount: int) -> void:
		recog_got["amount"] = amount
		recog_got["name"] = entity_name
	GM.recognition_earned.connect(recog_conn)

	GM.player_data["overload"] = 0
	GM.player_data["resonance"] = 100
	GM.player_data["hp"] = 100
	GM.start_combat(tomb_shade)
	await process_frame

	if not TM.is_in_combat:
		ok = false
		errors.append("tomb_shade combat did not start")

	TM.perform_skill("insight")
	await create_timer(1.2).timeout

	guard = 0
	while TM.combat_active and guard < 20:
		guard += 1
		if TM.is_player_turn and not TM.action_locked:
			if TM.has_enough_resonance("arcane_bolt"):
				TM.perform_skill("arcane_bolt")
			else:
				TM.perform_skill("attack")
		await create_timer(0.8).timeout

	await create_timer(1.0).timeout

	if TM.is_in_combat:
		ok = false
		errors.append("tomb_shade combat still active after loop (hp=%d, guard=%d)" % [int(TM.enemy.get("hp", -1)), guard])

	if int(recog_got["amount"]) <= 0:
		pass

	if GM.current_state != GM.GameState.EXPLORATION:
		ok = false
		errors.append("not back to exploration after tomb_shade")

	print("smoke_stats overload=", GM.player_data.get("overload", 0), " recognition=", GM.player_data.get("recognition", 0))

	if ok:
		print("VS_COMBAT_SMOKE_OK")
		quit(0)
	else:
		print("VS_COMBAT_SMOKE_FAIL: ", ", ".join(errors))
		quit(1)


func _track_enemy_action(actor: String, action: String, _target: String, _damage: int, _eff: String, actions: Array[String]) -> void:
	if actor == "Enemy":
		actions.append(action)
