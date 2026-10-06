extends CanvasLayer
class_name DialogBox
## 底部文本框，用于显示可交互物品的 message

signal message_finished

@onready var panel: NinePatchRect = $Panel
@onready var message_label: Label = $Panel/MessageLabel
@onready var arrow: TextureRect = $Panel/Arrow

var _showing: bool = false
var _arrow_tween: Tween = null

const ARROW_BOB_AMOUNT := 1.0
const ARROW_BOB_SPEED := 2.0


func _ready() -> void:
	add_to_group("dialog_box")
	visible = false
	if arrow:
		_start_arrow_animation()


func _input(event: InputEvent) -> void:
	if not _showing:
		return
	
	if event.is_action_pressed("interact") or event.is_action_pressed("confirm"):
		hide_message()
		get_viewport().set_input_as_handled()


func show_message(text: String, speaker_name: String = "") -> void:
	if _showing:
		return
	
	_showing = true
	visible = true
	
	if message_label:
		if speaker_name.is_empty():
			message_label.text = text
		else:
			message_label.text = "[%s]\n%s" % [speaker_name, text]
	
	GameManager.change_state(GameManager.GameState.DIALOGUE)


func hide_message() -> void:
	if not _showing:
		return
	
	_showing = false
	visible = false
	
	GameManager.change_state(GameManager.GameState.EXPLORATION)
	message_finished.emit()


func is_showing() -> bool:
	return _showing


func _start_arrow_animation() -> void:
	if arrow == null:
		return
	
	var base_y := arrow.position.y
	_arrow_tween = create_tween()
	_arrow_tween.set_loops()
	_arrow_tween.tween_property(arrow, "position:y", base_y - ARROW_BOB_AMOUNT, 0.5 / ARROW_BOB_SPEED)
	_arrow_tween.tween_property(arrow, "position:y", base_y + ARROW_BOB_AMOUNT, 0.5 / ARROW_BOB_SPEED)
