extends CanvasLayer

class_name AdventureHud

var game: Node
var view: Control

func _ready() -> void:
	layer = 20
	view = preload("res://scripts/hud_view.gd").new()
	view.hud = self
	view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(view)
