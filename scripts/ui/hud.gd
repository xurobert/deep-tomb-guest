extends CanvasLayer
class_name HUD
## Exploration HUD showing player stats

@onready var hp_label: Label = $Panel/VBox/HPLabel
@onready var recognition_label: Label = $Panel/VBox/RecognitionLabel
@onready var save_indicator: Label = $Panel/SaveIndicator


func _ready() -> void:
	GameManager.state_changed.connect(_on_state_changed)
	SaveManager.save_completed.connect(_on_save_completed)
	_update_display()


func _process(_delta: float) -> void:
	if GameManager.current_state == GameManager.GameState.EXPLORATION:
		_update_display()


func _update_display() -> void:
	if hp_label:
		hp_label.text = "HP: %d/%d" % [GameManager.player_data.hp, GameManager.player_data.max_hp]
	if recognition_label:
		recognition_label.text = "Recognition: %d" % GameManager.player_data.recognition


func _on_state_changed(new_state: GameManager.GameState) -> void:
	visible = new_state == GameManager.GameState.EXPLORATION


func _on_save_completed(success: bool) -> void:
	if save_indicator:
		save_indicator.text = "Saved!" if success else "Save Failed"
		save_indicator.visible = true
		
		await get_tree().create_timer(2.0).timeout
		save_indicator.visible = false
