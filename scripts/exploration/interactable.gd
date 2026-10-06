extends Node2D
class_name Interactable
## Base class for interactable objects in exploration

signal on_interact

@export var interaction_text: String = "检查"
@export var message: String = "一件远古文物静置于此。"
@export var prompt_color: Color = Color(1.0, 0.9, 0.3)
@export var set_flag_name: String = ""
@export var set_flag_value: bool = true
@export var grant_intel: String = ""

@onready var prompt_label: Label = $PromptLabel
@onready var area: Area2D = $Area2D


func _ready() -> void:
	if area:
		area.add_to_group("interactable")
	if prompt_label:
		prompt_label.text = "[E] " + interaction_text
		prompt_label.add_theme_color_override("font_color", prompt_color)
		prompt_label.visible = false


func interact() -> void:
	on_interact.emit()
	_on_interacted()


func _on_interacted() -> void:
	_show_message_in_dialog_box()
	_apply_flags_and_intel()


func show_prompt() -> void:
	if prompt_label:
		prompt_label.visible = true


func hide_prompt() -> void:
	if prompt_label:
		prompt_label.visible = false


func _show_message_in_dialog_box() -> void:
	var dialog_box := get_tree().get_first_node_in_group("dialog_box")
	if dialog_box and dialog_box.has_method("show_message"):
		dialog_box.show_message(message)
	else:
		print("[Interactable] %s" % message)


func _apply_flags_and_intel() -> void:
	if not set_flag_name.is_empty():
		GameManager.set_flag(set_flag_name, set_flag_value)
		print("[Interactable] 设置 flag: %s = %s" % [set_flag_name, set_flag_value])
	
	if not grant_intel.is_empty():
		var intel_flag := "intel_" + grant_intel
		if not GameManager.has_flag(intel_flag):
			GameManager.set_flag(intel_flag, true)
			print("[Interactable] 获得情报: %s" % grant_intel)
