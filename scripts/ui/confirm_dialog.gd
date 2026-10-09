extends CanvasLayer
class_name ConfirmDialog
## 可复用的确认对话框，传入文案和回调

signal confirmed
signal cancelled

@onready var panel: Control = $Panel
@onready var message_label: Label = $Panel/VBox/MessageLabel
@onready var yes_button: Button = $Panel/VBox/HBox/YesButton
@onready var no_button: Button = $Panel/VBox/HBox/NoButton

var _on_confirm: Callable
var _on_cancel: Callable
var _waiting_for_release: bool = false


func _ready() -> void:
	visible = false
	if yes_button:
		yes_button.pressed.connect(_on_yes_pressed)
	if no_button:
		no_button.pressed.connect(_on_no_pressed)


func show_confirm(message: String, on_confirm: Callable = Callable(), on_cancel: Callable = Callable()) -> void:
	_on_confirm = on_confirm
	_on_cancel = on_cancel
	_waiting_for_release = true
	
	if message_label:
		message_label.text = message
	
	visible = true
	GameManager.change_state(GameManager.GameState.DIALOGUE)
	
	call_deferred("_delayed_focus")


func _delayed_focus() -> void:
	if no_button:
		no_button.grab_focus()


func _on_yes_pressed() -> void:
	if _waiting_for_release:
		return
	visible = false
	GameManager.change_state(GameManager.GameState.EXPLORATION)
	confirmed.emit()
	if _on_confirm.is_valid():
		_on_confirm.call()


func _on_no_pressed() -> void:
	if _waiting_for_release:
		return
	visible = false
	GameManager.change_state(GameManager.GameState.EXPLORATION)
	cancelled.emit()
	if _on_cancel.is_valid():
		_on_cancel.call()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	
	if _waiting_for_release:
		if event.is_action_released("interact") or event.is_action_released("ui_accept"):
			_waiting_for_release = false
			get_viewport().set_input_as_handled()
		return
	
	if event.is_action_pressed("ui_cancel"):
		_on_no_pressed()
		get_viewport().set_input_as_handled()
