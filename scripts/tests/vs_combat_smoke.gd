extends SceneTree
## Headless smoke: start combat → attack → deep_echo → win → recognition
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

	var enemy := {
		"id": "tomb_shade",
		"name": "墓穴阴魂",
		"hp": 40,
		"max_hp": 40,
		"attack": 8,
		"defense": 2,
		"recognition_value": 15
	}

	var recog_got := {"amount": 0, "name": ""}
	GM.recognition_earned.connect(func(entity_name: String, amount: int) -> void:
		recog_got["amount"] = amount
		recog_got["name"] = entity_name
	)

	GM.start_combat(enemy)
	await process_frame

	if not TM.is_in_combat:
		ok = false
		errors.append("combat did not start")

	TM.perform_attack()
	await create_timer(1.2).timeout

	if TM.combat_active and TM.is_player_turn:
		TM.perform_skill("deep_echo")
		await create_timer(1.5).timeout

	var guard := 0
	while TM.combat_active and guard < 12:
		guard += 1
		if TM.is_player_turn and not TM.action_locked:
			TM.perform_attack()
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

	# Prefer that deep_echo raised overload at least once in a normal win path
	print("smoke_stats overload=", GM.player_data.get("overload", 0), " recognition=", GM.player_data.get("recognition", 0), " entity=", recog_got["name"])

	if ok:
		print("VS_COMBAT_SMOKE_OK")
		quit(0)
	else:
		print("VS_COMBAT_SMOKE_FAIL: ", ", ".join(errors))
		quit(1)
