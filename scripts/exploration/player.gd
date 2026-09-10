extends CharacterBody2D
class_name Player
## Player character controller for top-down exploration

signal interacted_with(interactable: Node2D)

const SPEED := 100.0
const TILE_SIZE := 16

var can_move: bool = true
var nearby_interactable: Node2D = null

@onready var sprite: Sprite2D = $Sprite2D
@onready var interaction_area: Area2D = $InteractionArea


func _ready() -> void:
	GameManager.state_changed.connect(_on_game_state_changed)
	interaction_area.area_entered.connect(_on_interaction_area_entered)
	interaction_area.area_exited.connect(_on_interaction_area_exited)


func _physics_process(_delta: float) -> void:
	if not can_move:
		velocity = Vector2.ZERO
		return
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * SPEED
	
	if velocity.length() > 0:
		_update_facing(input_dir)
	
	move_and_slide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_move and nearby_interactable:
		interacted_with.emit(nearby_interactable)
		if nearby_interactable.has_method("interact"):
			nearby_interactable.interact()


func _update_facing(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		sprite.flip_h = direction.x < 0


func _on_game_state_changed(new_state: GameManager.GameState) -> void:
	can_move = new_state == GameManager.GameState.EXPLORATION


func _on_interaction_area_entered(area: Area2D) -> void:
	if area.is_in_group("interactable"):
		nearby_interactable = area.get_parent()
		if nearby_interactable.has_method("show_prompt"):
			nearby_interactable.show_prompt()


func _on_interaction_area_exited(area: Area2D) -> void:
	if area.is_in_group("interactable") and nearby_interactable == area.get_parent():
		if nearby_interactable.has_method("hide_prompt"):
			nearby_interactable.hide_prompt()
		nearby_interactable = null
