extends CanvasLayer
class_name CombatUI
## 战斗 UI - 显示血条、共鸣槽、失控条、敌情状态和指令面板

# 敌方区域
@onready var turn_indicator: Label = $CombatPanel/TopPanel/EnemySection/TurnIndicator
@onready var enemy_name_label: Label = $CombatPanel/TopPanel/EnemySection/EnemyInfo/EnemyNameBox/NameLabel
@onready var enemy_intel_icon: TextureRect = $CombatPanel/TopPanel/EnemySection/EnemyInfo/EnemyNameBox/IntelRow/IntelIcon
@onready var enemy_intel_label: Label = $CombatPanel/TopPanel/EnemySection/EnemyInfo/EnemyNameBox/IntelRow/IntelLabel
@onready var enemy_weakness_icon: TextureRect = $CombatPanel/TopPanel/EnemySection/EnemyInfo/EnemyNameBox/IntelRow/WeaknessIcon
@onready var enemy_hp_bar: ProgressBar = $CombatPanel/TopPanel/EnemySection/EnemyInfo/EnemyHPBox/HPBar
@onready var enemy_hp_label: Label = $CombatPanel/TopPanel/EnemySection/EnemyInfo/EnemyHPBox/HPLabel

# 战场区域
@onready var battle_area: Control = $CombatPanel/BattleArea
@onready var enemy_sprite: Sprite2D = $CombatPanel/BattleArea/EnemySprite
@onready var hit_fx: Sprite2D = $CombatPanel/BattleArea/HitFX
@onready var skill_fx: Sprite2D = $CombatPanel/BattleArea/SkillFX
@onready var insight_fx: Sprite2D = $CombatPanel/BattleArea/InsightFX

# 伤害飘字容器
@onready var damage_popup_container: Control = $CombatPanel/BattleArea

# 情报图标纹理（预加载）
var tex_intel_unknown: Texture2D = preload("res://assets/art/ui/intel/ui_intel_unknown_32.png")
var tex_intel_revealed: Texture2D = preload("res://assets/art/ui/intel/ui_intel_revealed_32.png")

# 战斗日志
@onready var action_log: RichTextLabel = $CombatPanel/ActionLogPanel/ActionLog

# 玩家区域
@onready var player_name_label: Label = $CombatPanel/BottomPanel/HBox/PlayerSection/PlayerNameLabel
@onready var player_hp_bar: ProgressBar = $CombatPanel/BottomPanel/HBox/PlayerSection/HPRow/HPBar
@onready var player_hp_label: Label = $CombatPanel/BottomPanel/HBox/PlayerSection/HPRow/HPLabel
@onready var resonance_bar: ProgressBar = $CombatPanel/BottomPanel/HBox/PlayerSection/ResonanceRow/ResonanceBar
@onready var resonance_label: Label = $CombatPanel/BottomPanel/HBox/PlayerSection/ResonanceRow/ResonanceLabel
@onready var overload_bar: ProgressBar = $CombatPanel/BottomPanel/HBox/PlayerSection/OverloadRow/OverloadBar
@onready var overload_label: Label = $CombatPanel/BottomPanel/HBox/PlayerSection/OverloadRow/OverloadLabel

# 指令面板 - 五个技能按钮
@onready var attack_button: Button = $CombatPanel/BottomPanel/HBox/CommandSection/Actions/AttackButton
@onready var slash_button: Button = $CombatPanel/BottomPanel/HBox/CommandSection/Actions/SlashButton
@onready var arcane_bolt_button: Button = $CombatPanel/BottomPanel/HBox/CommandSection/Actions/ArcaneBoltButton
@onready var deep_echo_button: Button = $CombatPanel/BottomPanel/HBox/CommandSection/Actions/DeepEchoButton
@onready var insight_button: Button = $CombatPanel/BottomPanel/HBox/CommandSection/Actions/InsightButton
@onready var key_hints: Label = $CombatPanel/BottomPanel/HBox/CommandSection/KeyHints

# 敌情状态枚举
enum IntelState { UNKNOWN, PARTIAL, COMPLETE }
var current_intel_state: IntelState = IntelState.UNKNOWN
var revealed_weakness: String = ""

# 共鸣槽数据（暂用固定值，后续从 player_data 读取）
var max_resonance: int = 100
var current_resonance: int = 100

# 是否已显示过键位教学
var has_shown_key_tutorial: bool = false

# 属性图标缓存
var element_icons_16: Dictionary = {}
var element_icons_32: Dictionary = {}

# 伤害飘字颜色
const COLOR_ADVANTAGE := Color("#C9A24A")
const COLOR_DISADVANTAGE := Color("#7A8B9A")
const COLOR_NEUTRAL := Color("#D8D0C4")


func _ready() -> void:
	visible = false
	if skill_fx:
		skill_fx.visible = false
	if hit_fx:
		hit_fx.visible = false
	if insight_fx:
		insight_fx.visible = false

	TurnManager.combat_started.connect(_on_combat_started)
	TurnManager.combat_ended.connect(_on_combat_ended)
	TurnManager.turn_started.connect(_on_turn_started)
	TurnManager.action_performed.connect(_on_action_performed)
	TurnManager.overload_changed.connect(_on_overload_changed)
	TurnManager.skill_used.connect(_on_skill_used)
	TurnManager.enemy_weakness_revealed.connect(_on_enemy_weakness_revealed)

	_setup_skill_buttons()
	_load_element_icons()


func _load_element_icons() -> void:
	var elements := ["physical", "arcane", "shadow"]
	for elem_id: String in elements:
		var icon_16_path := "res://assets/art/ui/elements/ui_elem_%s_16.png" % elem_id
		var icon_32_path := "res://assets/art/ui/elements/ui_elem_%s_32.png" % elem_id
		if ResourceLoader.exists(icon_16_path):
			element_icons_16[elem_id] = load(icon_16_path)
		if ResourceLoader.exists(icon_32_path):
			element_icons_32[elem_id] = load(icon_32_path)


func _setup_skill_buttons() -> void:
	if attack_button:
		attack_button.pressed.connect(_on_attack_pressed)
		_set_button_element_icon(attack_button, "physical")
	if slash_button:
		slash_button.pressed.connect(_on_slash_pressed)
		_set_button_element_icon(slash_button, "physical")
	if arcane_bolt_button:
		arcane_bolt_button.pressed.connect(_on_arcane_bolt_pressed)
		_set_button_element_icon(arcane_bolt_button, "arcane")
	if deep_echo_button:
		deep_echo_button.pressed.connect(_on_deep_echo_pressed)
		_set_button_element_icon(deep_echo_button, "shadow")
	if insight_button:
		insight_button.pressed.connect(_on_insight_pressed)


func _set_button_element_icon(button: Button, element_id: String) -> void:
	if element_id.is_empty() or element_id == "none":
		button.icon = null
		return
	var icon: Texture2D = element_icons_16.get(element_id, null)
	if icon:
		button.icon = icon
		button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.expand_icon = false


func _input(event: InputEvent) -> void:
	if not visible or not TurnManager.combat_active:
		return
	if not TurnManager.is_player_turn or TurnManager.action_locked:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				_on_attack_pressed()
			KEY_2:
				_on_slash_pressed()
			KEY_3:
				_on_arcane_bolt_pressed()
			KEY_4:
				_on_deep_echo_pressed()
			KEY_5:
				_on_insight_pressed()
			KEY_J:
				_on_attack_pressed()
			KEY_K:
				_on_deep_echo_pressed()


func _on_combat_started() -> void:
	visible = true
	_clear_log()
	_reset_intel_state()
	_init_resonance()
	_update_all_displays()
	_log_message("[color=yellow]══ 战斗开始 ══[/color]")
	
	if not has_shown_key_tutorial:
		_show_key_tutorial()
		has_shown_key_tutorial = true
	
	if skill_fx:
		skill_fx.visible = false
	if hit_fx:
		hit_fx.visible = false
	if insight_fx:
		insight_fx.visible = false


func _on_combat_ended(victory: bool) -> void:
	_set_buttons_enabled(false)
	if victory:
		_log_message("[color=green]══ 胜利！ ══[/color]")
	else:
		_log_message("[color=red]══ 战败... ══[/color]")

	await get_tree().create_timer(1.5).timeout
	visible = false
	if skill_fx:
		skill_fx.visible = false
	if hit_fx:
		hit_fx.visible = false
	if insight_fx:
		insight_fx.visible = false


func _on_turn_started(is_player_turn: bool) -> void:
	_set_buttons_enabled(is_player_turn)
	_update_cooldown_display()
	if turn_indicator:
		if is_player_turn:
			turn_indicator.text = "== 你的回合 =="
			turn_indicator.modulate = Color(0.4, 1.0, 0.6)
		else:
			turn_indicator.text = "== 敌人回合 =="
			turn_indicator.modulate = Color(1.0, 0.5, 0.4)


func _on_action_performed(actor: String, action: String, target: String, damage: int, effectiveness: String) -> void:
	var color := "cyan" if actor == "Player" else "orange"
	var actor_name := "流浪者" if actor == "Player" else _get_enemy_display_name()
	var target_name := "流浪者" if target == "Player" else _get_enemy_display_name()
	
	var eff_text := ""
	var dmg_color := "#D8D0C4"
	match effectiveness:
		"advantage":
			eff_text = " [color=#C9A24A]克制！[/color]"
			dmg_color = "#C9A24A"
		"disadvantage":
			eff_text = " [color=#7A8B9A]被克制[/color]"
			dmg_color = "#7A8B9A"
	
	if damage > 0:
		_log_message("[color=%s]%s[/color] 对 %s 使用 [b]%s[/b]，造成 [color=%s]%d[/color] 点伤害！%s" % [color, actor_name, target_name, action, dmg_color, damage, eff_text])
	else:
		_log_message("[color=%s]%s[/color] 使用了 [b]%s[/b]！" % [color, actor_name, action])
	
	_update_all_displays()
	
	if actor == "Player" and damage > 0:
		_play_hit_effect()
		_spawn_damage_popup(damage, effectiveness)


func _on_overload_changed(current: int, maximum: int) -> void:
	if overload_bar:
		overload_bar.max_value = maximum
		overload_bar.value = current
	if overload_label:
		overload_label.text = "%d/%d" % [current, maximum]
		if current >= maximum * 0.8:
			overload_label.modulate = Color.RED
			_log_message("[color=red]⚠ 失控值危险！[/color]")
		elif current >= maximum * 0.5:
			overload_label.modulate = Color.YELLOW
		else:
			overload_label.modulate = Color(1, 0.6, 0.4)


func _on_skill_used(skill_id: String) -> void:
	if skill_id == "deep_echo_pulse":
		_consume_resonance(30)
	
	if skill_id != "deep_echo_pulse" or skill_fx == null:
		return
	skill_fx.visible = true
	skill_fx.modulate = Color(1, 1, 1, 1)
	var tween := create_tween()
	tween.tween_property(skill_fx, "modulate:a", 0.0, 0.6)
	await tween.finished
	skill_fx.visible = false


func _on_enemy_weakness_revealed(weakness_element: String) -> void:
	revealed_weakness = weakness_element
	current_intel_state = IntelState.COMPLETE
	_update_enemy_intel_display()
	_play_insight_fx()
	
	if weakness_element.is_empty():
		_log_message("[color=green]情报收集完毕！敌人没有明显弱点。[/color]")
	else:
		var elem_data := TurnManager.get_element_data(weakness_element)
		var elem_name: String = str(elem_data.get("name", weakness_element))
		_log_message("[color=green]情报收集完毕！弱点：%s[/color]" % elem_name)


func _on_attack_pressed() -> void:
	if not TurnManager.is_player_turn or TurnManager.action_locked:
		return
	_set_buttons_enabled(false)
	TurnManager.perform_skill("attack")


func _on_slash_pressed() -> void:
	if not TurnManager.is_player_turn or TurnManager.action_locked:
		return
	if TurnManager.is_skill_on_cooldown("slash"):
		return
	_set_buttons_enabled(false)
	TurnManager.perform_skill("slash")


func _on_arcane_bolt_pressed() -> void:
	if not TurnManager.is_player_turn or TurnManager.action_locked:
		return
	_set_buttons_enabled(false)
	TurnManager.perform_skill("arcane_bolt")


func _on_deep_echo_pressed() -> void:
	if not TurnManager.is_player_turn or TurnManager.action_locked:
		return
	_set_buttons_enabled(false)
	TurnManager.perform_skill("deep_echo_pulse")


func _on_insight_pressed() -> void:
	if not TurnManager.is_player_turn or TurnManager.action_locked:
		return
	_set_buttons_enabled(false)
	TurnManager.perform_skill("insight")


func _update_all_displays() -> void:
	var player_hp := TurnManager.get_player_hp()
	var player_max_hp: int = int(TurnManager.player.get("max_hp", 100))
	var enemy_hp := TurnManager.get_enemy_hp()
	var enemy_max_hp: int = int(TurnManager.enemy.get("max_hp", 50))
	var overload: int = int(TurnManager.player.get("overload", 0))
	var max_overload: int = int(TurnManager.player.get("max_overload", 100))

	if player_hp_bar:
		player_hp_bar.max_value = player_max_hp
		player_hp_bar.value = player_hp
	if player_hp_label:
		player_hp_label.text = "%d/%d" % [player_hp, player_max_hp]
	if player_name_label:
		player_name_label.text = str(TurnManager.player.get("name", "流浪者"))

	if enemy_hp_bar:
		enemy_hp_bar.max_value = enemy_max_hp
		enemy_hp_bar.value = enemy_hp
	if enemy_hp_label:
		enemy_hp_label.text = "HP: %d/%d" % [enemy_hp, enemy_max_hp]
	
	_update_enemy_intel_display()
	_on_overload_changed(overload, max_overload)
	_update_resonance_display()
	_update_cooldown_display()


func _update_cooldown_display() -> void:
	if slash_button:
		var cd := TurnManager.get_skill_cooldown("slash")
		if cd > 0:
			slash_button.disabled = true
			slash_button.text = "斩击 (%d)" % cd
		else:
			slash_button.text = "斩击"


func _set_buttons_enabled(enabled: bool) -> void:
	if attack_button:
		attack_button.disabled = not enabled
	if slash_button:
		var slash_cd := TurnManager.get_skill_cooldown("slash")
		slash_button.disabled = not enabled or slash_cd > 0
	if arcane_bolt_button:
		arcane_bolt_button.disabled = not enabled
	if deep_echo_button:
		deep_echo_button.disabled = not enabled
	if insight_button:
		insight_button.disabled = not enabled


func _log_message(msg: String) -> void:
	if action_log:
		action_log.append_text(msg + "\n")


func _clear_log() -> void:
	if action_log:
		action_log.clear()


# ========== 敌情状态系统 ==========

func _reset_intel_state() -> void:
	current_intel_state = IntelState.UNKNOWN
	revealed_weakness = ""
	if enemy_weakness_icon:
		enemy_weakness_icon.visible = false


func _get_enemy_display_name() -> String:
	match current_intel_state:
		IntelState.UNKNOWN:
			return "???"
		IntelState.PARTIAL, IntelState.COMPLETE:
			return str(TurnManager.enemy.get("name", "敌人"))
	return "敌人"


func _update_enemy_intel_display() -> void:
	if enemy_name_label:
		enemy_name_label.text = _get_enemy_display_name()
	
	if enemy_intel_label:
		match current_intel_state:
			IntelState.UNKNOWN:
				enemy_intel_label.text = "情报: ???"
				enemy_intel_label.modulate = Color(0.6, 0.6, 0.7)
			IntelState.PARTIAL:
				enemy_intel_label.text = "情报: 部分"
				enemy_intel_label.modulate = Color(1.0, 0.9, 0.5)
			IntelState.COMPLETE:
				enemy_intel_label.text = "情报: 完整"
				enemy_intel_label.modulate = Color(0.5, 1.0, 0.6)
	
	if enemy_intel_icon:
		match current_intel_state:
			IntelState.UNKNOWN:
				enemy_intel_icon.texture = tex_intel_unknown
				enemy_intel_icon.modulate = Color(0.6, 0.6, 0.7)
			IntelState.PARTIAL, IntelState.COMPLETE:
				enemy_intel_icon.texture = tex_intel_revealed
				enemy_intel_icon.modulate = Color(0.5, 1.0, 0.6) if current_intel_state == IntelState.COMPLETE else Color(1.0, 0.9, 0.5)
	
	if enemy_weakness_icon:
		if current_intel_state == IntelState.COMPLETE and not revealed_weakness.is_empty():
			var weakness_tex: Texture2D = element_icons_32.get(revealed_weakness, null)
			if weakness_tex:
				enemy_weakness_icon.texture = weakness_tex
				enemy_weakness_icon.visible = true
			else:
				enemy_weakness_icon.visible = false
		else:
			enemy_weakness_icon.visible = false


func reveal_enemy_intel(level: IntelState) -> void:
	current_intel_state = level
	_update_enemy_intel_display()
	match level:
		IntelState.PARTIAL:
			_log_message("[color=yellow]获得了部分情报！[/color]")
			_play_insight_fx()
		IntelState.COMPLETE:
			_log_message("[color=green]情报收集完毕！弱点已揭示。[/color]")
			_play_insight_fx()


# ========== 共鸣槽系统 ==========

func _init_resonance() -> void:
	var player_resonance = GameManager.player_data.get("resonance", -1)
	var player_max_resonance = GameManager.player_data.get("max_resonance", -1)
	
	if player_resonance >= 0:
		current_resonance = int(player_resonance)
	else:
		current_resonance = max_resonance
	
	if player_max_resonance > 0:
		max_resonance = int(player_max_resonance)


func _update_resonance_display() -> void:
	if resonance_bar:
		resonance_bar.max_value = max_resonance
		resonance_bar.value = current_resonance
	if resonance_label:
		resonance_label.text = "%d/%d" % [current_resonance, max_resonance]
		if current_resonance <= max_resonance * 0.2:
			resonance_label.modulate = Color.RED
		elif current_resonance <= max_resonance * 0.5:
			resonance_label.modulate = Color.YELLOW
		else:
			resonance_label.modulate = Color(0.6, 0.5, 1.0)


func _consume_resonance(amount: int) -> void:
	current_resonance = maxi(current_resonance - amount, 0)
	_update_resonance_display()
	if current_resonance <= 0:
		_log_message("[color=red]共鸣能量耗尽！[/color]")


# ========== 视觉反馈 ==========

func _play_hit_effect() -> void:
	if hit_fx:
		hit_fx.visible = true
		hit_fx.modulate = Color(1, 1, 1, 1)
		var fx_tween := create_tween()
		fx_tween.tween_property(hit_fx, "modulate:a", 0.0, 0.3)
		fx_tween.tween_callback(func(): hit_fx.visible = false)
	
	if enemy_sprite:
		var orig_pos := enemy_sprite.position
		var tween := create_tween()
		tween.tween_property(enemy_sprite, "modulate", Color(1.5, 0.5, 0.5), 0.05)
		tween.tween_property(enemy_sprite, "position", orig_pos + Vector2(5, 0), 0.03)
		tween.tween_property(enemy_sprite, "position", orig_pos + Vector2(-5, 0), 0.03)
		tween.tween_property(enemy_sprite, "position", orig_pos, 0.03)
		tween.tween_property(enemy_sprite, "modulate", Color.WHITE, 0.1)


func _play_insight_fx() -> void:
	if insight_fx:
		insight_fx.visible = true
		insight_fx.modulate = Color(1, 1, 1, 1)
		var tween := create_tween()
		tween.tween_property(insight_fx, "scale", Vector2(2.5, 2.5), 0.2).from(Vector2(1.5, 1.5))
		tween.parallel().tween_property(insight_fx, "modulate:a", 0.0, 0.4)
		tween.tween_callback(func(): insight_fx.visible = false; insight_fx.scale = Vector2(2, 2))


func _spawn_damage_popup(damage: int, effectiveness: String) -> void:
	if not damage_popup_container:
		return
	
	var popup := Label.new()
	popup.text = str(damage)
	popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup.add_theme_font_size_override("font_size", 20)
	
	match effectiveness:
		"advantage":
			popup.modulate = COLOR_ADVANTAGE
		"disadvantage":
			popup.modulate = COLOR_DISADVANTAGE
		_:
			popup.modulate = COLOR_NEUTRAL
	
	popup.position = Vector2(-20, -60)
	damage_popup_container.add_child(popup)
	
	var tween := create_tween()
	tween.tween_property(popup, "position:y", popup.position.y - 40, 0.6)
	tween.parallel().tween_property(popup, "modulate:a", 0.0, 0.6).set_delay(0.3)
	tween.tween_callback(popup.queue_free)


func _show_key_tutorial() -> void:
	_log_message("[color=gray]─────────────────────[/color]")
	_log_message("[color=gray]◆ 操作提示 ◆[/color]")
	_log_message("[color=gray][1] 攻击 - 稳定物理伤害[/color]")
	_log_message("[color=gray][2] 斩击 - 强力斩击，冷却 2 回合[/color]")
	_log_message("[color=gray][3] 咒术飞弹 - 咒术伤害，+15 失控[/color]")
	_log_message("[color=gray][4] 异能共鸣 - 高伤害，+30 失控[/color]")
	_log_message("[color=gray][5] 洞察 - 揭示敌人弱点[/color]")
	_log_message("[color=gray]─────────────────────[/color]")
