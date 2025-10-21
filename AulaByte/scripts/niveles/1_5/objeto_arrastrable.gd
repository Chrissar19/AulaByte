extends TextureRect
class_name ObjetoArrastrable

@export_enum("hardware", "no-hardware") var correct_category: String = "hardware"

signal return_requested

var _start_position: Vector2

func _ready() -> void:
    
    mouse_filter = Control.MOUSE_FILTER_STOP
    _start_position = position

func _get_drag_data(_at_position: Vector2) -> Variant:
    var data := {
        "type": "draggable_obj",
        "from": self,
        "correct_category": correct_category
    }
    var preview := duplicate() as TextureRect
    preview.modulate.a = 0.6
    
    var visual_size: Vector2 = preview.size
    var visual_scale: Vector2 = preview.scale
        
    var pivot_x: float = -(visual_scale.x / (2.0 * (1.0 - visual_scale.x))) * visual_size.x
    var pivot_y: float = -(visual_scale.y / (2.0 * (1.0 - visual_scale.y))) * visual_size.y
    preview.pivot_offset = Vector2(pivot_x, pivot_y)
    
    set_drag_preview(preview)
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
