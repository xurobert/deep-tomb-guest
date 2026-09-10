extends Interactable
class_name CombatTrigger
## Triggers combat when player interacts or steps on it

@export var enemy_id: String = "tomb_shade"
@export var trigger_on_touch: bool = false

var enemies_data: Dictionary = {}


func _ready() -> void:
	super._ready()
	_load_enemy_data()
	
	if trigger_on_touch and area:
		area.body_entered.connect(_on_body_entered)


func _load_enemy_data() -> void:
	var file := FileAccess.open("res://data/enemies.json", FileAccess.READ)
	if file:
		var json := JSON.new()
		if json.parse(file.get_as_text()) == OK:
			enemies_data = json.data
		file.close()


func _on_interacted() -> void:
	_start_combat()


func _on_body_entered(body: Node2D) -> void:
	if body is Player and trigger_on_touch:
		_start_combat()


func _start_combat() -> void:
	var enemy := enemies_data.get(enemy_id, {}).duplicate(true)
	if enemy.is_empty():
		enemy = {
			"id": "unknown",
			"name": "Unknown Enemy",
			"hp": 30,
			"max_hp": 30,
			"attack": 5,
			"defense": 1,
			"recognition_value": 5
		}
	
	GameManager.start_combat(enemy)
