extends CanvasLayer
class_name CombatUI
## 战斗 UI - 显示血条、共鸣槽、失控条、敌情状态和指令面板

# 敌方区域
@onready var turn_indicator: Label = $CombatPanel/TopPanel/EnemySection/TurnIndicator
@onready var enemy_name_label: Label = $CombatPanel/TopPanel/EnemySection/EnemyInfo/EnemyNameBox/NameLabel
@onready var enemy_intel_label: Label = $CombatPanel/TopPanel/EnemySection/EnemyInfo/EnemyNameBox/IntelLabel
@onready var enemy_hp_bar: ProgressBar = $CombatPanel/TopPanel/EnemySection/EnemyInfo/EnemyHPBox/HPBar
@onready var enemy_hp_label: Label = $CombatPanel/TopPanel/EnemySection/EnemyInfo/EnemyHPBox/HPLabel

# 战场区域
@onready var battle_area: Control = $CombatPanel/BattleArea
@onready var enemy_sprite: Sprite2D = $CombatPanel/BattleArea/EnemySprite
@onready var skill_fx: Sprite2D = $CombatPanel/BattleArea/SkillFX

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

# 指令面板
@onready var attack_button: Button = $CombatPanel/BottomPanel/HBox/CommandSection/Actions/AttackButton
@onready var skill_button: Button = $CombatPanel/BottomPanel/HBox/CommandSection/Actions/SkillButton
@onready var insight_button: Button = $CombatPanel/BottomPanel/HBox/CommandSection/Actions/InsightButton
@onready var key_hints: Label = $CombatPanel/BottomPanel/HBox/CommandSection/KeyHints

# 敌情状态枚举（预留给后续情报状态机）
enum IntelState { UNKNOWN, PARTIAL, COMPLETE }
var current_intel_state: IntelState = IntelState.UNKNOWN

# 共鸣槽数据（暂用固定值，后续从 player_data 读取）
var max_resonance: int = 100
var current_resonance: int = 100

# 是否已显示过键位教学
var has_shown_key_tutorial: bool = false


func _ready() -> void:
	visible = false
	if skill_fx:
		skill_fx.visible = false

	TurnManager.combat_started.connect(_on_combat_started)
	TurnManager.combat_ended.connect(_on_combat_ended)
	TurnManager.turn_started.connect(_on_turn_started)
	TurnManager.action_performed.connect(_on_action_performed)
	TurnManager.overload_changed.connect(_on_overload_changed)
	TurnManager.skill_used.connect(_on_skill_used)

	if attack_button:
		attack_button.pressed.connect(_on_attack_pressed)
	if skill_button:
		skill_button.pressed.connect(_on_skill_pressed)
	if insight_button:
		insight_button.pressed.connect(_on_insight_pressed)


func _input(event: InputEvent) -> void:
	if not visible or not TurnManager.combat_active:
		return
	if not TurnManager.is_player_turn or TurnManager.action_locked:
		return

	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed):
		if event is InputEventKey:
			match event.keycode:
				KEY_J:
					_on_attack_pressed()
				KEY_K:
					_on_skill_pressed()


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


func _on_turn_started(is_player_turn: bool) -> void:
	_set_buttons_enabled(is_player_turn)
	if turn_indicator:
		if is_player_turn:
			turn_indicator.text = "== 你的回合 =="
			turn_indicator.modulate = Color(0.4, 1.0, 0.6)
		else:
			turn_indicator.text = "== 敌人回合 =="
			turn_indicator.modulate = Color(1.0, 0.5, 0.4)


func _on_action_performed(actor: String, action: String, target: String, damage: int) -> void:
	var color := "cyan" if actor == "Player" else "orange"
	var actor_name := "流浪者" if actor == "Player" else _get_enemy_display_name()
	var target_name := "流浪者" if target == "Player" else _get_enemy_display_name()
	_log_message("[color=%s]%s[/color] 对 %s 使用 [b]%s[/b]，造成 [color=red]%d[/color] 点伤害！" % [color, actor_name, target_name, action, damage])
	_update_all_displays()
	
	if actor == "Player" and damage > 0:
		_play_hit_effect()


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
	if skill_id == "deep_echo":
		_consume_resonance(30)
	
	if skill_id != "deep_echo" or skill_fx == null:
		return
	skill_fx.visible = true
	skill_fx.modulate = Color(1, 1, 1, 1)
	var tween := create_tween()
	tween.tween_property(skill_fx, "modulate:a", 0.0, 0.6)
	await tween.finished
	skill_fx.visible = false


func _on_attack_pressed() -> void:
	if not TurnManager.is_player_turn or TurnManager.action_locked:
		return
	_set_buttons_enabled(false)
	TurnManager.perform_attack()


func _on_skill_pressed() -> void:
	if not TurnManager.is_player_turn or TurnManager.action_locked:
		return
	_set_buttons_enabled(false)
	TurnManager.perform_skill("deep_echo")


func _on_insight_pressed() -> void:
	pass


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


func _set_buttons_enabled(enabled: bool) -> void:
	if attack_button:
		attack_button.disabled = not enabled
	if skill_button:
		skill_button.disabled = not enabled


func _log_message(msg: String) -> void:
	if action_log:
		action_log.append_text(msg + "\n")


func _clear_log() -> void:
	if action_log:
		action_log.clear()


# ========== 敌情状态系统（预留接口） ==========

func _reset_intel_state() -> void:
	current_intel_state = IntelState.UNKNOWN


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
				enemy_intel_label.text = "[情报: ???]"
				enemy_intel_label.modulate = Color(0.6, 0.6, 0.7)
			IntelState.PARTIAL:
				enemy_intel_label.text = "[情报: 部分]"
				enemy_intel_label.modulate = Color(1.0, 0.9, 0.5)
			IntelState.COMPLETE:
				enemy_intel_label.text = "[情报: 完整]"
				enemy_intel_label.modulate = Color(0.5, 1.0, 0.6)


func reveal_enemy_intel(level: IntelState) -> void:
	current_intel_state = level
	_update_enemy_intel_display()
	match level:
		IntelState.PARTIAL:
			_log_message("[color=yellow]获得了部分情报！[/color]")
		IntelState.COMPLETE:
			_log_message("[color=green]情报收集完毕！弱点已揭示。[/color]")


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
	if enemy_sprite:
		var orig_pos := enemy_sprite.position
		var tween := create_tween()
		tween.tween_property(enemy_sprite, "modulate", Color(1.5, 0.5, 0.5), 0.05)
		tween.tween_property(enemy_sprite, "position", orig_pos + Vector2(5, 0), 0.03)
		tween.tween_property(enemy_sprite, "position", orig_pos + Vector2(-5, 0), 0.03)
		tween.tween_property(enemy_sprite, "position", orig_pos, 0.03)
		tween.tween_property(enemy_sprite, "modulate", Color.WHITE, 0.1)


func _show_key_tutorial() -> void:
	_log_message("[color=gray]─────────────────────[/color]")
	_log_message("[color=gray]◆ 操作提示 ◆[/color]")
	_log_message("[color=gray][J] 攻击 - 稳定伤害[/color]")
	_log_message("[color=gray][K] 异能共鸣 - 高伤害，消耗共鸣，增加失控[/color]")
	_log_message("[color=gray]─────────────────────[/color]")
