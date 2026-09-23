extends Interactable
class_name SavePoint
## Save point that allows player to save their progress

signal save_successful
signal save_failed

@onready var animation_player: AnimationPlayer = $AnimationPlayer if has_node("AnimationPlayer") else null


func _ready() -> void:
	interaction_text = "魂灯存档"
	message = "一座散发幽蓝光芒的石座灯，可以在此保存进度。"
	prompt_color = Color(0.4, 0.75, 1.0)
	super._ready()


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
