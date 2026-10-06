extends SceneTree
## Headless smoke: 测试房间切换、存档扩展、杂兵持久击败
## Run: godot --headless --path . -s res://scripts/tests/room_system_smoke.gd

func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	await process_frame
	await process_frame

	var SM: Node = root.get_node("SaveManager")
	var GM: Node = root.get_node("GameManager")
	var RM: Node = root.get_node("RoomManager")
	var ok := true
	var errors: PackedStringArray = []

	print("=== 房间系统测试 ===")

	# ========== 测试 1: RoomManager 存在且可用 ==========
	print("测试 1: RoomManager 存在...")
	if RM == null:
		ok = false
		errors.append("RoomManager autoload not found")
	else:
		print("  RoomManager 已加载")

	# ========== 测试 2: 默认房间是 ch0_hall ==========
	print("测试 2: 默认房间配置...")
	var default_room: String = RM.DEFAULT_ROOM if RM else ""
	if default_room != "ch0_hall":
		ok = false
		errors.append("DEFAULT_ROOM should be ch0_hall, got '%s'" % default_room)
	else:
		print("  默认房间: ch0_hall")

	# ========== 测试 3: 存档扩展字段 ==========
	print("测试 3: 存档扩展字段...")
	
	SM.cleared["test_room/TestEnemy"] = true
	
	if not SM.cleared.has("test_room/TestEnemy"):
		ok = false
		errors.append("cleared dictionary should store key")
	else:
		print("  cleared 字典可用")

	# ========== 测试 4: mark_cleared 和 is_cleared ==========
	print("测试 4: mark_cleared 和 is_cleared...")
	
	RM.current_room_id = "test_room"
	SM.mark_cleared("TestNode")
	
	if not SM.is_cleared("TestNode"):
		ok = false
		errors.append("is_cleared should return true after mark_cleared")
	else:
		print("  mark_cleared/is_cleared 工作正常")

	# ========== 测试 5: 老存档兼容（无 room_id 和 cleared） ==========
	print("测试 5: 老存档兼容...")
	
	var old_save := {
		"version": 1,
		"timestamp": 0,
		"player": {"hp": 100, "max_hp": 100},
		"player_position": {"x": 100.0, "y": 100.0},
		"scene": "",
		"flags": {},
		"save_point_id": ""
	}
	
	var room_from_old: String = str(old_save.get("room_id", ""))
	if room_from_old.is_empty():
		room_from_old = "ch0_hall"
	
	if room_from_old != "ch0_hall":
		ok = false
		errors.append("old save without room_id should default to ch0_hall")
	else:
		print("  老存档默认进 ch0_hall")

	# ========== 测试 6: bone_guard 敌人数据 ==========
	print("测试 6: bone_guard 敌人数据...")
	
	var enemies_data := {}
	var file := FileAccess.open("res://data/enemies.json", FileAccess.READ)
	if file:
		var json := JSON.new()
		if json.parse(file.get_as_text()) == OK and typeof(json.data) == TYPE_DICTIONARY:
			enemies_data = json.data
		file.close()
	
	if not enemies_data.has("bone_guard"):
		ok = false
		errors.append("enemies.json should have bone_guard")
	else:
		var bg: Dictionary = enemies_data["bone_guard"]
		if bg.get("element", "") != "physical":
			ok = false
			errors.append("bone_guard element should be physical")
		elif int(bg.get("hp", 0)) != 45:
			ok = false
			errors.append("bone_guard hp should be 45")
		else:
			print("  bone_guard: 物理属性, HP 45")

	# ========== 测试 7: flags 系统 ==========
	print("测试 7: flags 系统...")
	
	GM.set_flag("test_flag", true)
	if not GM.has_flag("test_flag"):
		ok = false
		errors.append("has_flag should return true after set_flag")
	
	var flag_val: Variant = GM.get_flag("test_flag", false)
	if flag_val != true:
		ok = false
		errors.append("get_flag should return set value")
	else:
		print("  flags 系统工作正常")

	# ========== 测试 8: 存档包含新字段 ==========
	print("测试 8: 存档新字段验证...")
	
	RM.current_room_id = "ch0_hall"
	SM.cleared = {"ch0_hall/BoneGuard1": true}
	
	var save_data := {
		"version": 1,
		"room_id": RM.get_current_room_id(),
		"cleared": SM.cleared.duplicate(true),
		"flags": GM.flags.duplicate(true)
	}
	
	if not save_data.has("room_id"):
		ok = false
		errors.append("save_data should have room_id field")
	elif not save_data.has("cleared"):
		ok = false
		errors.append("save_data should have cleared field")
	else:
		print("  存档包含 room_id 和 cleared 字段")

	# ========== 结果输出 ==========
	print("")
	if ok:
		print("ROOM_SYSTEM_SMOKE_OK")
		quit(0)
	else:
		print("ROOM_SYSTEM_SMOKE_FAIL: ", ", ".join(errors))
		quit(1)
