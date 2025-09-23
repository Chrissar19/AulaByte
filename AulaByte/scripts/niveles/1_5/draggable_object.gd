extends TextureRect
class_name DraggableObject

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
