extends CanvasLayer
class_name AreaBanner
## 区域横幅 - 进入新区域时显示

signal banner_hidden

@onready var panel: NinePatchRect = $Panel
@onready var text_label: Label = $Panel/TextLabel

const DISPLAY_DURATION := 2.5
const FADE_DURATION := 0.5


func _ready() -> void:
	add_to_group("area_banner")
	visible = false


func show_banner(text: String) -> void:
	if text_label:
		text_label.text = text
	
	visible = true
	if panel:
		panel.modulate.a = 0.0
	
	var tween := create_tween()
	if panel:
		tween.tween_property(panel, "modulate:a", 1.0, FADE_DURATION)
		tween.tween_interval(DISPLAY_DURATION)
		tween.tween_property(panel, "modulate:a", 0.0, FADE_DURATION)
	else:
		tween.tween_interval(DISPLAY_DURATION + FADE_DURATION * 2)
	tween.tween_callback(_on_banner_finished)


func _on_banner_finished() -> void:
	visible = false
	banner_hidden.emit()
