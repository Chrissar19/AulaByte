extends Sprite2D
class_name PiezaTangram

signal soltar(global_pos: Vector2)

@export var color_objetivo: Color
@export var draggable: bool = true
@export var rot_step_deg: float = 15.0

var _arrastrando := false
var _offset := Vector2.ZERO
var _actividad: Actividad6

func _ready() -> void:
    _actividad = get_tree().get_first_node_in_group("Actividad6") as Actividad6
    if _actividad == null:
        _actividad = get_parent().get_parent() as Actividad6

func _input(event: InputEvent) -> void:
    if not draggable:
        return
    if event is InputEventMouseButton:
        var mb := event as InputEventMouseButton
        if mb.button_index == MOUSE_BUTTON_LEFT:
            if mb.pressed and _sobre_mi():
                _arrastrando = true
                _offset = global_position - get_global_mouse_position()
            elif not mb.pressed and _arrastrando:
                _arrastrando = false
                if is_instance_valid(_actividad):
                    _actividad.intentar_colocar(self, color_objetivo)
        if mb.pressed and (mb.button_index == MOUSE_BUTTON_WHEEL_UP or mb.button_index == MOUSE_BUTTON_WHEEL_DOWN):
            var dir := 0.0
            if mb.button_index == MOUSE_BUTTON_WHEEL_UP:
                dir = 1.0
            else:
                dir = -1.0
            rotation_degrees = round((rotation_degrees + dir * rot_step_deg) / rot_step_deg) * rot_step_deg

func _process(_dt: float) -> void:
    if _arrastrando:
        global_position = get_global_mouse_position() + _offset

func _sobre_mi() -> bool:
    var vp := get_viewport()
    var mouse := vp.get_mouse_position()
    var lp := to_local(mouse)
    # Si hay Sprite2D hijo, se puede usar get_rect(); aquí un radio simple:
    if lp.length() <= 64.0:
        return true
    return false
