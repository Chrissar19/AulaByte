extends TextureRect
class_name TeclaArrastrable

@export_enum("letras", "numeros", "simbolos") var categoria_correcta: String = "letras"

signal retornar
var _posicion_inicial: Vector2

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_STOP
    _posicion_inicial = position

func _get_drag_data(at_position: Vector2) -> Variant:
    var data := {
        "type": "draggable_obj",
        "from": self,
        "categoria_correcta": categoria_correcta
    }
    var vista := duplicate() as TextureRect
    vista.modulate.a = 0.6
    set_drag_preview(vista)

    visible = false
    return data

func _notification(what: int) -> void:
    if what == NOTIFICATION_DRAG_END:
        if not is_queued_for_deletion():
            volver_a_empezar()

func volver_a_empezar() -> void:
    visible = true
    position = _posicion_inicial
    emit_signal("retornar")
