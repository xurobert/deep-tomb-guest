extends Interactable
class_name CombatTrigger
## Triggers combat when player interacts or steps on it

@export var enemy_id: String = "tomb_shade"
@export var trigger_on_touch: bool = false

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


func _load_enemy_data() -> void:
	var file := FileAccess.open("res://data/enemies.json", FileAccess.READ)
	if file:
		var json := JSON.new()
		if json.parse(file.get_as_text()) == OK and typeof(json.data) == TYPE_DICTIONARY:
			enemies_data = json.data
		file.close()


func _on_interacted() -> void:
	_start_combat()


func _on_body_entered(body: Node2D) -> void:
	if body is Player and trigger_on_touch:
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
		_defeated = true
		hide_prompt()
		visible = false
		if area:
			area.set_deferred("monitoring", false)
			area.set_deferred("monitorable", false)
