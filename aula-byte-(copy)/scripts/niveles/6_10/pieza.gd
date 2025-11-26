extends TextureRect
class_name PiezaPuzzle

signal colocada

@export var posicion_correcta: Vector2
@export var tolerancia_px: float = 16.0

var _arrastrando: bool = false
var _offset := Vector2.ZERO

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_STOP

func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed:
            _arrastrando = true
            _offset = get_global_mouse_position() - global_position
            z_index = 50
        else:
            _arrastrando = false
            _verificar_posicion()
            z_index = 1
    elif event is InputEventMouseMotion and _arrastrando:
        global_position = get_global_mouse_position() - _offset

func _verificar_posicion() -> void:
    if global_position.distance_to(posicion_correcta) <= tolerancia_px:
        global_position = posicion_correcta
        colocada.emit()
        set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
