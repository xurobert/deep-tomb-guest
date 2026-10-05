extends Interactable
class_name CombatTrigger
## Triggers combat when player interacts or steps on it

@export var enemy_id: String = "tomb_shade"
@export var trigger_on_touch: bool = false
@export var require_flag: String = ""
@export var confirm_message: String = ""
@export var defeat_flag: String = ""

var enemies_data: Dictionary = {}
var _defeated: bool = false
var _starting: bool = false


func _ready() -> void:
	if interaction_text == "检查":
		interaction_text = "挑战"
	prompt_color = Color(1.0, 0.35, 0.35)
	super._ready()
	_load_enemy_data()
	if trigger_on_touch and area:
		area.body_entered.connect(_on_body_entered)
	
	GameManager.combat_defeat.connect(_on_combat_defeat)
	SaveManager.load_completed.connect(_on_load_completed)
	
	call_deferred("_restore_from_flags")


func _restore_from_flags() -> void:
	var flag_name := _get_defeat_flag()
	if not flag_name.is_empty() and GameManager.get_flag(flag_name, false):
		_set_defeated_state()


func _on_load_completed(_success: bool) -> void:
	_restore_from_flags()


func _get_defeat_flag() -> String:
	if not defeat_flag.is_empty():
		return defeat_flag
	var raw: Variant = enemies_data.get(enemy_id, {})
	if typeof(raw) == TYPE_DICTIONARY:
		return str(raw.get("defeat_flag", ""))
	return ""


func _set_defeated_state() -> void:
	_defeated = true
	hide_prompt()
	visible = false
	if area:
		area.set_deferred("monitoring", false)
		area.set_deferred("monitorable", false)


func _load_enemy_data() -> void:
	var file := FileAccess.open("res://data/enemies.json", FileAccess.READ)
	if file:
		var json := JSON.new()
		if json.parse(file.get_as_text()) == OK and typeof(json.data) == TYPE_DICTIONARY:
			enemies_data = json.data
		file.close()


func _on_interacted() -> void:
	if not require_flag.is_empty() and not GameManager.has_flag(require_flag):
		print("[CombatTrigger] 需要 flag: %s 才能进入" % require_flag)
		return
	
	if not confirm_message.is_empty():
		_show_confirm_dialog()
	else:
		_start_combat()


func _show_confirm_dialog() -> void:
	GameManager.show_confirm(confirm_message, _start_combat)


func _on_body_entered(body: Node2D) -> void:
	if body is Player and trigger_on_touch:
		if require_flag.is_empty() or GameManager.has_flag(require_flag):
			_start_combat()


func _normalize_enemy(raw: Dictionary) -> Dictionary:
	var enemy: Dictionary = raw.duplicate(true)
	enemy["id"] = str(enemy.get("id", enemy_id))
	enemy["name"] = str(enemy.get("name", "未知敌人"))
	enemy["hp"] = int(enemy.get("hp", 30))
	enemy["max_hp"] = int(enemy.get("max_hp", enemy["hp"]))
	enemy["attack"] = int(enemy.get("attack", 5))
	enemy["defense"] = int(enemy.get("defense", 1))
	enemy["recognition_value"] = int(enemy.get("recognition_value", 5))
	return enemy


func _start_combat() -> void:
	if _defeated or _starting:
		return
	if GameManager.current_state != GameManager.GameState.EXPLORATION:
		return
	if TurnManager.is_in_combat or TurnManager.combat_active:
		return

	_starting = true
	var raw: Variant = enemies_data.get(enemy_id, {})
	var enemy: Dictionary
	if typeof(raw) == TYPE_DICTIONARY and not raw.is_empty():
		enemy = _normalize_enemy(raw)
	else:
		enemy = {
			"id": "unknown",
			"name": "未知敌人",
			"hp": 30,
			"max_hp": 30,
			"attack": 5,
			"defense": 1,
			"recognition_value": 5
		}

	if not TurnManager.combat_ended.is_connected(_on_combat_ended):
		TurnManager.combat_ended.connect(_on_combat_ended)
	GameManager.start_combat(enemy)
	_starting = false


func _on_combat_ended(victory: bool) -> void:
	if victory:
		var flag_name := _get_defeat_flag()
		if not flag_name.is_empty():
			GameManager.set_flag(flag_name, true)
			print("[CombatTrigger] 设置 flag: %s = true" % flag_name)
		_set_defeated_state()


func _on_combat_defeat() -> void:
	SaveManager.handle_combat_defeat()
