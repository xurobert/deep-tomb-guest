extends Interactable
class_name SavePoint
## Save point that allows player to save their progress

signal save_successful
signal save_failed

@onready var animation_player: AnimationPlayer = $AnimationPlayer if has_node("AnimationPlayer") else null


func _ready() -> void:
	super._ready()
	interaction_text = "保存"
	message = "一个休憩之所..."
	if prompt_label:
		prompt_label.text = "[E] " + interaction_text


func _on_interacted() -> void:
	GameManager.change_state(GameManager.GameState.SAVING)
	
	if animation_player:
		animation_player.play("saving")
	
	var success := SaveManager.save_game()
	
	if success:
		save_successful.emit()
		print("[SavePoint] Game saved successfully!")
	else:
		save_failed.emit()
		print("[SavePoint] Failed to save game.")
	
	await get_tree().create_timer(0.5).timeout
	GameManager.change_state(GameManager.GameState.EXPLORATION)
