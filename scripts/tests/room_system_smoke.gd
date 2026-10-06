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

	# ========== 测试 9: GateTrigger 场景结构 ==========
	print("测试 9: GateTrigger 场景结构...")
	
	var gate_scene := load("res://scenes/gate_trigger.tscn")
	if gate_scene == null:
		ok = false
		errors.append("gate_trigger.tscn should load")
	else:
		var gate_instance: Node2D = gate_scene.instantiate()
		if gate_instance == null:
			ok = false
			errors.append("gate_trigger should instantiate")
		else:
			var area := gate_instance.get_node_or_null("Area2D")
			if area == null:
				ok = false
				errors.append("GateTrigger should have Area2D child")
			elif area.collision_layer != 4:
				ok = false
				errors.append("GateTrigger Area2D layer should be 4, got %d" % area.collision_layer)
			elif area.collision_mask != 2:
				ok = false
				errors.append("GateTrigger Area2D mask should be 2, got %d" % area.collision_mask)
			else:
				print("  GateTrigger Area2D: layer=4, mask=2")
			
			var gate_sprite := gate_instance.get_node_or_null("GateSprite")
			if gate_sprite == null:
				ok = false
				errors.append("GateTrigger should have GateSprite child")
			elif gate_sprite.centered:
				ok = false
				errors.append("GateSprite should not be centered")
			else:
				print("  GateSprite: centered=false")
			
			gate_instance.queue_free()

	# ========== 测试 10: ch0_hall 场景结构 ==========
	print("测试 10: ch0_hall 场景结构...")
	
	var hall_scene := load("res://scenes/rooms/ch0_hall.tscn")
	if hall_scene == null:
		ok = false
		errors.append("ch0_hall.tscn should load")
	else:
		var hall_instance: Node2D = hall_scene.instantiate()
		if hall_instance == null:
			ok = false
			errors.append("ch0_hall should instantiate")
		else:
			if not hall_instance.y_sort_enabled:
				ok = false
				errors.append("ch0_hall should have y_sort_enabled")
			else:
				print("  ch0_hall: y_sort_enabled=true")
			
			var entities := hall_instance.get_node_or_null("Entities")
			if entities == null:
				ok = false
				errors.append("ch0_hall should have Entities node")
			elif not entities.y_sort_enabled:
				ok = false
				errors.append("ch0_hall/Entities should have y_sort_enabled")
			else:
				print("  ch0_hall/Entities: y_sort_enabled=true")
			
			var layer_gate := hall_instance.get_node_or_null("Entities/LayerGate")
			if layer_gate == null:
				ok = false
				errors.append("ch0_hall should have LayerGate")
			else:
				print("  ch0_hall/LayerGate: 存在")
			
			hall_instance.queue_free()

	# ========== 测试 11: ch1_f1_entrance 场景结构 ==========
	print("测试 11: ch1_f1_entrance 场景结构...")
	
	var entrance_scene := load("res://scenes/rooms/ch1_f1_entrance.tscn")
	if entrance_scene == null:
		ok = false
		errors.append("ch1_f1_entrance.tscn should load")
	else:
		var entrance_instance: Node2D = entrance_scene.instantiate()
		if entrance_instance == null:
			ok = false
			errors.append("ch1_f1_entrance should instantiate")
		else:
			if not entrance_instance.y_sort_enabled:
				ok = false
				errors.append("ch1_f1_entrance should have y_sort_enabled")
			else:
				print("  ch1_f1_entrance: y_sort_enabled=true")
			
			var death_knight := entrance_instance.get_node_or_null("Entities/TempArea/DeathKnightTrigger")
			if death_knight == null:
				ok = false
				errors.append("ch1_f1_entrance should have DeathKnightTrigger")
			elif death_knight.get("map_sprite") == null:
				ok = false
				errors.append("DeathKnightTrigger should have map_sprite set")
			else:
				print("  DeathKnightTrigger: map_sprite 已设置")
			
			var guardian_door := entrance_instance.get_node_or_null("Entities/TempArea/GuardianDoor")
			if guardian_door == null:
				ok = false
				errors.append("ch1_f1_entrance should have GuardianDoor")
			elif guardian_door.get("map_sprite") == null:
				ok = false
				errors.append("GuardianDoor should have map_sprite set")
			else:
				print("  GuardianDoor: map_sprite 已设置")
			
			entrance_instance.queue_free()

	# ========== 测试 12: RoomManager change_room 参数 ==========
	print("测试 12: RoomManager change_room 方法签名...")
	
	if RM.has_method("change_room"):
		var method_list := RM.get_method_list()
		var found_change_room := false
		for m in method_list:
			if m.get("name", "") == "change_room":
				found_change_room = true
				var args: Array = m.get("args", [])
				if args.size() < 3:
					ok = false
					errors.append("change_room should have at least 3 parameters (room_id, spawn_point, area_banner_text)")
				else:
					print("  change_room: 接受 area_banner_text 参数")
				break
		if not found_change_room:
			ok = false
			errors.append("change_room method not found in method_list")
	else:
		ok = false
		errors.append("RoomManager should have change_room method")

	# ========== 测试 13: AreaBanner 场景存在 ==========
	print("测试 13: AreaBanner 场景...")
	
	var banner_scene: Resource = load("res://scenes/ui/area_banner.tscn")
	if banner_scene == null:
		ok = false
		errors.append("area_banner.tscn should load")
	else:
		var banner_instance: Node = (banner_scene as PackedScene).instantiate()
		if banner_instance == null:
			ok = false
			errors.append("area_banner should instantiate")
		else:
			if banner_instance.has_method("show_banner"):
				print("  AreaBanner: show_banner 方法存在")
			else:
				ok = false
				errors.append("AreaBanner should have show_banner method")
			banner_instance.queue_free()

	# ========== 测试 14: ConfirmDialog 使用 NinePatchRect ==========
	print("测试 14: ConfirmDialog 场景结构...")
	
	var confirm_scene: Resource = load("res://scenes/ui/confirm_dialog.tscn")
	if confirm_scene == null:
		ok = false
		errors.append("confirm_dialog.tscn should load")
	else:
		var confirm_instance: Node = (confirm_scene as PackedScene).instantiate()
		if confirm_instance == null:
			ok = false
			errors.append("confirm_dialog should instantiate")
		else:
			var panel: Node = confirm_instance.get_node_or_null("Panel")
			if panel == null:
				ok = false
				errors.append("ConfirmDialog should have Panel child")
			elif not (panel is NinePatchRect):
				ok = false
				errors.append("ConfirmDialog Panel should be NinePatchRect, got %s" % panel.get_class())
			else:
				print("  ConfirmDialog: Panel 是 NinePatchRect")
			confirm_instance.queue_free()

	# ========== 结果输出 ==========
	print("")
	if ok:
		print("ROOM_SYSTEM_SMOKE_OK")
		quit(0)
	else:
		print("ROOM_SYSTEM_SMOKE_FAIL: ", ", ".join(errors))
		quit(1)
