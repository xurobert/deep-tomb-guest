extends Node2D
class_name Interactable
## Base class for interactable objects in exploration

signal on_interact

@export var interaction_text: String = "Examine"
@export var message: String = "An ancient artifact rests here."

@onready var prompt_label: Label = $PromptLabel
@onready var area: Area2D = $Area2D


func _ready() -> void:
	if area:
		area.add_to_group("interactable")
	if prompt_label:
		prompt_label.text = "[E] " + interaction_text
		prompt_label.visible = false


func interact() -> void:
	on_interact.emit()
	_on_interacted()


func _on_interacted() -> void:
	print("[Interactable] ", message)


func show_prompt() -> void:
	if prompt_label:
		prompt_label.visible = true


func hide_prompt() -> void:
	if prompt_label:
		prompt_label.visible = false
