extends CanvasLayer
class_name RecognitionToast
## Shows a toast notification when recognition is earned (gaze/acknowledgment)

@onready var panel: Panel = $Panel
@onready var title_label: Label = $Panel/VBox/TitleLabel
@onready var message_label: Label = $Panel/VBox/MessageLabel
@onready var amount_label: Label = $Panel/VBox/AmountLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var toast_queue: Array[Dictionary] = []
var is_showing: bool = false


func _ready() -> void:
	visible = false
	GameManager.recognition_earned.connect(_on_recognition_earned)
	GameManager.guardian_result.connect(_on_guardian_result)
	GameManager.chapter_complete.connect(_on_chapter_complete)


func _on_recognition_earned(entity_name: String, amount: int) -> void:
	var toast_data := {
		"entity": entity_name,
		"amount": int(amount),
		"type": "victory"
	}
	toast_queue.append(toast_data)
	_try_show_next()


func _on_guardian_result(result: String, recognition: int) -> void:
	if result == "recognized":
		var toast_data := {
			"entity": "守护者",
			"amount": recognition,
			"type": "guardian_recognized",
			"message": "……住手。你看穿了我的本质，却没被力量吞噬。"
		}
		toast_queue.insert(0, toast_data)
		_try_show_next()


func _on_chapter_complete(chapter: int) -> void:
	var toast_data := {
		"type": "chapter_complete",
		"chapter": chapter
	}
	toast_queue.append(toast_data)
	_try_show_next()
	
	await get_tree().create_timer(3.0).timeout
	SaveManager.save_game("checkpoint_ch%d_complete" % chapter)


func _try_show_next() -> void:
	if is_showing or toast_queue.is_empty():
		return

	is_showing = true
	var data: Dictionary = toast_queue.pop_front()
	var toast_type: String = str(data.get("type", "victory"))
	
	match toast_type:
		"guardian_recognized":
			_show_guardian_toast(str(data.get("message", "")), int(data.get("amount", 30)))
		"chapter_complete":
			_show_chapter_toast(int(data.get("chapter", 1)))
		_:
			_show_victory_toast(str(data.get("entity", "敌人")), int(data.get("amount", 0)))


func _show_victory_toast(entity_name: String, amount: int) -> void:
	if title_label:
		title_label.text = "战斗胜利"
	if message_label:
		message_label.text = ""
	if amount_label:
		amount_label.text = "认可 +%d" % amount

	visible = true
	await _animate_toast()
	visible = false
	is_showing = false
	_try_show_next()


func _show_guardian_toast(message: String, amount: int) -> void:
	if title_label:
		title_label.text = "守护者的认可"
	if message_label:
		message_label.text = message
	if amount_label:
		amount_label.text = "+%d 认可" % amount

	visible = true
	await _animate_toast(3.0)
	visible = false
	is_showing = false
	_try_show_next()


func _show_chapter_toast(chapter: int) -> void:
	if title_label:
		title_label.text = "第%d章 完成" % chapter
	if message_label:
		message_label.text = ""
	if amount_label:
		amount_label.text = ""

	visible = true
	await _animate_toast(2.5)
	visible = false
	is_showing = false
	_try_show_next()


func _animate_toast(display_time: float = 2.0) -> void:
	if animation_player and animation_player.has_animation("show"):
		animation_player.play("show")
		await animation_player.animation_finished
	else:
		panel.modulate.a = 0.0
		var tween := create_tween()
		tween.tween_property(panel, "modulate:a", 1.0, 0.3)
		await tween.finished

		await get_tree().create_timer(display_time).timeout

		tween = create_tween()
		tween.tween_property(panel, "modulate:a", 0.0, 0.5)
		await tween.finished
