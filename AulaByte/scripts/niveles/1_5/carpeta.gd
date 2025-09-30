extends Panel
class_name Carpeta

@export_enum("hardware", "no-hardware") var category: String = "hardware"
signal item_dropped(correct: bool)

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_PASS

func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
    return typeof(data) == TYPE_DICTIONARY \
        and data.has("type") and data["type"] == "draggable_obj" \
        and data.has("from") and data.has("correct_category")

func _drop_data(_pos: Vector2, data: Variant) -> void:
    var obj: ObjetoArrastrable = data["from"]
    var correct: bool = (data["correct_category"] == category)

    if correct:
        obj.queue_free()
    else:
        obj.return_to_start()

    item_dropped.emit(correct)
