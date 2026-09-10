extends CanvasLayer
class_name CombatUI
## Combat UI displaying HP bars, overload meter, and action buttons

@onready var combat_panel: Panel = $CombatPanel
@onready var player_hp_bar: ProgressBar = $CombatPanel/VBox/PlayerSection/HPBar
@onready var player_hp_label: Label = $CombatPanel/VBox/PlayerSection/HPLabel
@onready var enemy_hp_bar: ProgressBar = $CombatPanel/VBox/EnemySection/HPBar
@onready var enemy_hp_label: Label = $CombatPanel/VBox/EnemySection/HPLabel
@onready var enemy_name_label: Label = $CombatPanel/VBox/EnemySection/NameLabel
@onready var overload_bar: ProgressBar = $CombatPanel/VBox/OverloadSection/OverloadBar
@onready var overload_label: Label = $CombatPanel/VBox/OverloadSection/OverloadLabel
@onready var action_log: RichTextLabel = $CombatPanel/VBox/ActionLog
@onready var attack_button: Button = $CombatPanel/VBox/Actions/AttackButton
@onready var skill_button: Button = $CombatPanel/VBox/Actions/SkillButton
@onready var turn_indicator: Label = $CombatPanel/VBox/TurnIndicator


func _ready() -> void:
	visible = false
	
	TurnManager.combat_started.connect(_on_combat_started)
	TurnManager.combat_ended.connect(_on_combat_ended)
	TurnManager.turn_started.connect(_on_turn_started)
	TurnManager.action_performed.connect(_on_action_performed)
	TurnManager.overload_changed.connect(_on_overload_changed)
	
	if attack_button:
		attack_button.pressed.connect(_on_attack_pressed)
	if skill_button:
		skill_button.pressed.connect(_on_skill_pressed)


func _on_combat_started() -> void:
	visible = true
	_clear_log()
	_update_all_displays()
	_log_message("[color=yellow]Combat begins![/color]")


func _on_combat_ended(victory: bool) -> void:
	_set_buttons_enabled(false)
	if victory:
		_log_message("[color=green]Victory![/color]")
	else:
		_log_message("[color=red]Defeated...[/color]")
	
	await get_tree().create_timer(1.5).timeout
	visible = false


func _on_turn_started(is_player_turn: bool) -> void:
	_set_buttons_enabled(is_player_turn)
	if turn_indicator:
		turn_indicator.text = "YOUR TURN" if is_player_turn else "ENEMY TURN"
		turn_indicator.modulate = Color.GREEN if is_player_turn else Color.RED


func _on_action_performed(actor: String, action: String, target: String, damage: int) -> void:
	var color := "cyan" if actor == "Player" else "orange"
	_log_message("[color=%s]%s[/color] uses %s on %s for [color=red]%d[/color] damage!" % [color, actor, action, target, damage])
	_update_all_displays()


func _on_overload_changed(current: int, maximum: int) -> void:
	if overload_bar:
		overload_bar.max_value = maximum
		overload_bar.value = current
	if overload_label:
		overload_label.text = "Overload: %d/%d" % [current, maximum]
		if current >= maximum * 0.8:
			overload_label.modulate = Color.RED
		elif current >= maximum * 0.5:
			overload_label.modulate = Color.YELLOW
		else:
			overload_label.modulate = Color.WHITE


func _on_attack_pressed() -> void:
	TurnManager.perform_attack()


func _on_skill_pressed() -> void:
	TurnManager.perform_skill("deep_echo")


func _update_all_displays() -> void:
	var player_hp := TurnManager.get_player_hp()
	var player_max_hp: int = TurnManager.player.get("max_hp", 100)
	var enemy_hp := TurnManager.get_enemy_hp()
	var enemy_max_hp: int = TurnManager.enemy.get("max_hp", 50)
	var overload: int = TurnManager.player.get("overload", 0)
	var max_overload: int = TurnManager.player.get("max_overload", 100)
	
	if player_hp_bar:
		player_hp_bar.max_value = player_max_hp
		player_hp_bar.value = player_hp
	if player_hp_label:
		player_hp_label.text = "HP: %d/%d" % [player_hp, player_max_hp]
	
	if enemy_hp_bar:
		enemy_hp_bar.max_value = enemy_max_hp
		enemy_hp_bar.value = enemy_hp
	if enemy_hp_label:
		enemy_hp_label.text = "HP: %d/%d" % [enemy_hp, enemy_max_hp]
	if enemy_name_label:
		enemy_name_label.text = TurnManager.enemy.get("name", "Enemy")
	
	_on_overload_changed(overload, max_overload)


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
