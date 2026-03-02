extends TextureRect
class_name ObjetoArrastrable

@export_enum("hardware", "no-hardware") var correct_category: String = "hardware"

signal return_requested

var _start_position: Vector2

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_start_position = position

func _get_drag_data(at_position: Vector2) -> Variant:
	var data := {
		"type": "draggable_obj",
		"from": self,
		"correct_category": correct_category
	}
	
	var preview := TextureRect.new()
	preview.texture = texture
	preview.expand_mode = expand_mode
	preview.stretch_mode = stretch_mode
	preview.size = size
	preview.scale = scale
	preview.modulate.a = 0.6
	
	preview.visible = true 
	
	var offset = at_position * scale
	preview.position = -offset
	
	var preview_container = Control.new()
	preview_container.add_child(preview)
	
	set_drag_preview(preview_container)

	visible = false
	return data

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		if not is_queued_for_deletion():
			return_to_start()

func return_to_start() -> void:
	visible = true
	position = _start_position
	emit_signal("return_requested")
