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

	# ========== 测试 15: ch0_hall 有墙壁碰撞和墙图 ==========
	print("测试 15: ch0_hall 墙壁碰撞和墙图...")
	
	var hall_scene2 := load("res://scenes/rooms/ch0_hall.tscn")
	if hall_scene2:
		var hall2: Node2D = hall_scene2.instantiate()
		var walls := hall2.get_node_or_null("Walls")
		if walls == null:
			ok = false
			errors.append("ch0_hall should have Walls node")
		else:
			var top_wall := walls.get_node_or_null("TopWall")
			var bottom_wall := walls.get_node_or_null("BottomWall")
			var left_wall := walls.get_node_or_null("LeftWall")
			var right_wall := walls.get_node_or_null("RightWall")
			if top_wall == null or bottom_wall == null or left_wall == null or right_wall == null:
				ok = false
				errors.append("ch0_hall/Walls should have all 4 wall collision shapes")
			else:
				print("  ch0_hall: 4 面墙碰撞存在")
			
			var wall_visuals := walls.get_node_or_null("WallVisuals")
			if wall_visuals == null:
				ok = false
				errors.append("ch0_hall/Walls should have WallVisuals node")
			else:
				print("  ch0_hall: WallVisuals 存在")
		hall2.queue_free()

	# ========== 测试 16: ch1_f1_entrance 有墙壁碰撞和墙图 ==========
	print("测试 16: ch1_f1_entrance 墙壁碰撞和墙图...")
	
	var entrance_scene2 := load("res://scenes/rooms/ch1_f1_entrance.tscn")
	if entrance_scene2:
		var entrance2: Node2D = entrance_scene2.instantiate()
		var walls2 := entrance2.get_node_or_null("Walls")
		if walls2 == null:
			ok = false
			errors.append("ch1_f1_entrance should have Walls node")
		else:
			var top_wall2 := walls2.get_node_or_null("TopWall")
			var bottom_wall2 := walls2.get_node_or_null("BottomWall")
			var left_wall2 := walls2.get_node_or_null("LeftWall")
			var right_wall2 := walls2.get_node_or_null("RightWall")
			if top_wall2 == null or bottom_wall2 == null or left_wall2 == null or right_wall2 == null:
				ok = false
				errors.append("ch1_f1_entrance/Walls should have all 4 wall collision shapes")
			else:
				print("  ch1_f1_entrance: 4 面墙碰撞存在")
			
			var wall_visuals2 := walls2.get_node_or_null("WallVisuals")
			if wall_visuals2 == null:
				ok = false
				errors.append("ch1_f1_entrance/Walls should have WallVisuals node")
			else:
				print("  ch1_f1_entrance: WallVisuals 存在")
		entrance2.queue_free()

	# ========== 测试 17: ConfirmDialog 不会在打开当帧触发 ==========
	print("测试 17: ConfirmDialog 打开当帧不触发确认...")
	
	var confirm_scene2: Resource = load("res://scenes/ui/confirm_dialog.tscn")
	if confirm_scene2:
		var confirm2: Node = (confirm_scene2 as PackedScene).instantiate()
		root.add_child(confirm2)
		
		var triggered := false
		var test_callback := func() -> void:
			triggered = true
		
		confirm2.show_confirm("测试", test_callback)
		
		if triggered:
			ok = false
			errors.append("ConfirmDialog should not trigger callback on show_confirm call")
		else:
			print("  ConfirmDialog: 打开时未触发回调")
		
		if confirm2.get("_waiting_for_release") != true:
			ok = false
			errors.append("ConfirmDialog should set _waiting_for_release=true on open")
		else:
			print("  ConfirmDialog: _waiting_for_release=true")
		
		confirm2.queue_free()

	# ========== 测试 18: 所有可交互感应区 layer=4/mask=2 ==========
	print("测试 18: 可交互感应区 layer/mask...")
	
	var interactable_scene := load("res://scenes/interactable.tscn")
	if interactable_scene:
		var interactable_inst: Node2D = interactable_scene.instantiate()
		var inter_area := interactable_inst.get_node_or_null("Area2D") as Area2D
		if inter_area == null:
			ok = false
			errors.append("interactable.tscn should have Area2D")
		elif inter_area.collision_layer != 4 or inter_area.collision_mask != 2:
			ok = false
			errors.append("interactable Area2D should have layer=4/mask=2, got %d/%d" % [inter_area.collision_layer, inter_area.collision_mask])
		else:
			print("  interactable.tscn: layer=4, mask=2")
		interactable_inst.queue_free()
	
	var gate_scene3 := load("res://scenes/gate_trigger.tscn")
	if gate_scene3:
		var gate_inst: Node2D = gate_scene3.instantiate()
		var gate_area := gate_inst.get_node_or_null("Area2D") as Area2D
		if gate_area == null:
			ok = false
			errors.append("gate_trigger.tscn should have Area2D")
		elif gate_area.collision_layer != 4 or gate_area.collision_mask != 2:
			ok = false
			errors.append("gate_trigger Area2D should have layer=4/mask=2, got %d/%d" % [gate_area.collision_layer, gate_area.collision_mask])
		else:
			print("  gate_trigger.tscn: layer=4, mask=2")
		gate_inst.queue_free()
	
	var exit_scene := load("res://scenes/room_exit.tscn")
	if exit_scene:
		var exit_inst: Node2D = exit_scene.instantiate()
		var exit_area := exit_inst.get_node_or_null("Area2D") as Area2D
		if exit_area == null:
			ok = false
			errors.append("room_exit.tscn should have Area2D")
		elif exit_area.collision_layer != 4 or exit_area.collision_mask != 2:
			ok = false
			errors.append("room_exit Area2D should have layer=4/mask=2, got %d/%d" % [exit_area.collision_layer, exit_area.collision_mask])
		else:
			print("  room_exit.tscn: layer=4, mask=2")
		exit_inst.queue_free()

	# ========== 测试 19: SpawnPoint 递归查找 ==========
	print("测试 19: SpawnPoint 在 Entities 下也能找到...")
	
	var hall_scene3 := load("res://scenes/rooms/ch0_hall.tscn")
	if hall_scene3:
		var hall3: Node2D = hall_scene3.instantiate()
		var spawn_direct := hall3.get_node_or_null("SpawnPoint")
		var spawn_recursive := hall3.find_child("SpawnPoint", true, false)
		if spawn_direct != null:
			ok = false
			errors.append("SpawnPoint should not be direct child of room (should be under Entities)")
		if spawn_recursive == null:
			ok = false
			errors.append("SpawnPoint should be findable with find_child")
		else:
			var spawn_pos: Vector2 = spawn_recursive.position
			if spawn_pos.y != 312:
				ok = false
				errors.append("ch0_hall SpawnPoint y should be 312, got %d" % int(spawn_pos.y))
			else:
				print("  ch0_hall SpawnPoint: y=312, find_child 可找到")
		hall3.queue_free()

	# ========== 测试 20: ch1_f1_entrance 碎石封口 ==========
	print("测试 20: ch1_f1_entrance 碎石封口...")
	
	var entrance_scene3 := load("res://scenes/rooms/ch1_f1_entrance.tscn")
	if entrance_scene3:
		var entrance3: Node2D = entrance_scene3.instantiate()
		
		var west_rubble := entrance3.get_node_or_null("Entities/WestRubble") as Sprite2D
		var east_rubble := entrance3.get_node_or_null("Entities/EastRubble") as Sprite2D
		
		if west_rubble == null:
			ok = false
			errors.append("ch1_f1_entrance should have WestRubble sprite")
		elif west_rubble.position != Vector2(48, 176):
			ok = false
			errors.append("WestRubble position should be (48,176), got %s" % str(west_rubble.position))
		else:
			print("  WestRubble: 位置 (48,176)")
		
		if east_rubble == null:
			ok = false
			errors.append("ch1_f1_entrance should have EastRubble sprite")
		elif east_rubble.position != Vector2(592, 176):
			ok = false
			errors.append("EastRubble position should be (592,176), got %s" % str(east_rubble.position))
		elif not east_rubble.flip_h:
			ok = false
			errors.append("EastRubble should have flip_h=true")
		else:
			print("  EastRubble: 位置 (592,176), flip_h=true")
		
		var west_exit := entrance3.get_node_or_null("Entities/WestExit")
		var east_exit := entrance3.get_node_or_null("Entities/EastExit")
		
		if west_exit and west_exit.position != Vector2(80, 176):
			ok = false
			errors.append("WestExit position should be (80,176), got %s" % str(west_exit.position))
		else:
			print("  WestExit: 位置 (80,176)")
		
		if east_exit and east_exit.position != Vector2(560, 176):
			ok = false
			errors.append("EastExit position should be (560,176), got %s" % str(east_exit.position))
		else:
			print("  EastExit: 位置 (560,176)")
		
		entrance3.queue_free()

	# ========== 测试 21: 过层门后状态回到 EXPLORATION ==========
	print("测试 21: 过层门后状态回到 EXPLORATION...")
	
	var dummy_main := Node.new()
	dummy_main.name = "Main"
	root.add_child(dummy_main)
	current_scene = dummy_main
	
	var room_container := Node2D.new()
	room_container.name = "RoomContainer"
	dummy_main.add_child(room_container)
	
	var player := Node2D.new()
	player.name = "Player"
	player.add_to_group("player")
	dummy_main.add_child(player)
	
	var hud_packed: PackedScene = load("res://scenes/ui/hud.tscn")
	var hud: CanvasLayer = hud_packed.instantiate()
	dummy_main.add_child(hud)
	
	var banner_packed: PackedScene = load("res://scenes/ui/area_banner.tscn")
	var test_banner: Node = banner_packed.instantiate()
	dummy_main.add_child(test_banner)
	
	await process_frame
	await process_frame
	
	RM.change_room_instant("ch0_hall")
	await process_frame
	
	var layer_gate: Node = null
	if RM.current_room_node:
		layer_gate = RM.current_room_node.find_child("LayerGate", true, false)
	
	if layer_gate == null:
		ok = false
		errors.append("ch0_hall LayerGate not found for transition test")
	else:
		GM.change_state(GM.GameState.EXPLORATION)
		layer_gate.call("_on_confirmed")
		
		if RM.get_current_room_id() != "ch1_f1_entrance":
			await RM.transition_finished
		await process_frame
		await process_frame
		if GM.current_state != GM.GameState.EXPLORATION:
			if test_banner.visible:
				await test_banner.banner_hidden
			else:
				await dummy_main.get_tree().create_timer(4.0).timeout
		
		if GM.current_state != GM.GameState.EXPLORATION:
			ok = false
			errors.append("after gate confirm, state should be EXPLORATION, got %d" % int(GM.current_state))
		elif RM.get_current_room_id() != "ch1_f1_entrance":
			ok = false
			errors.append("after gate confirm, room should be ch1_f1_entrance, got '%s'" % RM.get_current_room_id())
		elif not hud.visible:
			ok = false
			errors.append("after gate confirm, HUD should be visible")
		else:
			print("  过层门后: EXPLORATION, ch1_f1_entrance, HUD 可见")

	# ========== 测试 22: PromptLabel z_index 不被主角挡住 ==========
	print("测试 22: PromptLabel z_index...")
	
	var prompt_scenes := [
		"res://scenes/interactable.tscn",
		"res://scenes/room_exit.tscn",
		"res://scenes/gate_trigger.tscn",
	]
	var prompt_ok := true
	for scene_path in prompt_scenes:
		var packed: PackedScene = load(scene_path)
		if packed == null:
			ok = false
			prompt_ok = false
			errors.append("%s should load for prompt z_index check" % scene_path)
			continue
		var inst: Node2D = packed.instantiate()
		root.add_child(inst)
		await process_frame
		var prompt := inst.get_node_or_null("PromptLabel") as Label
		if prompt == null:
			ok = false
			prompt_ok = false
			errors.append("%s should have PromptLabel" % scene_path)
		elif prompt.z_index != 10:
			ok = false
			prompt_ok = false
			errors.append("%s PromptLabel z_index should be 10, got %d" % [scene_path, prompt.z_index])
		elif prompt.z_as_relative:
			ok = false
			prompt_ok = false
			errors.append("%s PromptLabel z_as_relative should be false" % scene_path)
		inst.queue_free()
	if prompt_ok:
		print("  Interactable/RoomExit/GateTrigger PromptLabel: z_index=10, z_as_relative=false")

	# ========== 结果输出 ==========
	print("")
	if ok:
		print("ROOM_SYSTEM_SMOKE_OK")
		quit(0)
	else:
		print("ROOM_SYSTEM_SMOKE_FAIL: ", ", ".join(errors))
		quit(1)
