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


func _on_recognition_earned(entity_name: String, amount: int) -> void:
	var toast_data := {
		"entity": entity_name,
		"amount": amount
	}
	toast_queue.append(toast_data)
	_try_show_next()


func _try_show_next() -> void:
	if is_showing or toast_queue.is_empty():
		return
	
	is_showing = true
	var data: Dictionary = toast_queue.pop_front()
	_show_toast(data.entity, data.amount)


func _show_toast(entity_name: String, amount: int) -> void:
	if title_label:
		title_label.text = "获得认可"
	if message_label:
		message_label.text = "%s认可了你的存在..." % entity_name
	if amount_label:
		amount_label.text = "+%d 认可" % amount
	
	visible = true
	
	if animation_player and animation_player.has_animation("show"):
		animation_player.play("show")
		await animation_player.animation_finished
	else:
		panel.modulate.a = 0.0
		var tween := create_tween()
		tween.tween_property(panel, "modulate:a", 1.0, 0.3)
		await tween.finished
		
		await get_tree().create_timer(2.0).timeout
		
		tween = create_tween()
		tween.tween_property(panel, "modulate:a", 0.0, 0.5)
		await tween.finished
	
	visible = false
	is_showing = false
	_try_show_next()
