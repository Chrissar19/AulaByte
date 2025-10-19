extends Sprite2D
class_name PiezaTangram

enum TipoPieza {
    TRIANGULO_GRANDE,
    TRIANGULO_MEDIANO,
    TRIANGULO_PEQUENO,
    CUADRADO,
    PARALELOGRAMO
}

@export var tipo: TipoPieza = TipoPieza.TRIANGULO_GRANDE
@export var area_colision: Area2D

var rotation_steps: int = 0
var en_posicion_correcta: bool = false
var sensor_actual: Area2D = null
var locked: bool = false
# tolerancia por defecto en pixeles
var tolerancia_posicion: float = 15.0

func init_rotation_steps() -> void:
    rotation_steps = int(round(rotation_degrees / Actividad6.GRADOS_ROTACION)) % Actividad6.MAX_ROTACION
    rotation_degrees = rotation_steps * Actividad6.GRADOS_ROTACION

func _ready() -> void:
    init_rotation_steps()
    if area_colision:
        area_colision.area_entered.connect(_on_area_entered)
        area_colision.area_exited.connect(_on_area_exited)


func _on_area_entered(area: Area2D) -> void:
    if area.has_meta("tipo_esperado"):
        var tipo_esperado = area.get_meta("tipo_esperado")
        if tipo_esperado == tipo and not locked:
            sensor_actual = area
            verificar_posicion()


func _on_area_exited(area: Area2D) -> void:
    if area == sensor_actual:
        en_posicion_correcta = false
        sensor_actual = null
        actualizar_visual()


func verificar_posicion() -> void:
    if not sensor_actual:
        en_posicion_correcta = false
        actualizar_visual()
        return

    var expected_steps: int = int(sensor_actual.get_meta("expected_steps", 0))
    var tolerancia_pos: float = float(sensor_actual.get_meta("tolerancia_posicion", tolerancia_posicion))

    var distancia: float = global_position.distance_to(sensor_actual.global_position)
    
    en_posicion_correcta = (rotation_steps == expected_steps) and (distancia <= tolerancia_pos)
    actualizar_visual()
    
    if en_posicion_correcta:
        lock_in_place(sensor_actual)


func lock_in_place(sensor: Area2D) -> void:
    if locked:
        return
    locked = true
    
    global_position = sensor.global_position
    rotation_degrees = int(sensor.get_meta("expected_steps", rotation_steps)) * Actividad6.GRADOS_ROTACION

    # Desactivar colisiones y sensor para evitar reentradas
    if area_colision:
        area_colision.monitoring = false
        area_colision.set_deferred("monitoring", false)

    actualizar_visual()

    # Llamar hook opcional 'on_locked' sólo si existe
    if has_method("on_locked"):
        call("on_locked")


func actualizar_visual() -> void:
    if locked:
        # apariencia bloqueada (por ejemplo, destacar)
        modulate = Color(1, 1, 1, 1)
    elif en_posicion_correcta:
        modulate = Color(1, 1, 1, 1)
    else:
        modulate = Color(1, 1, 1, 0.9)


func get_tipo_pieza() -> String:
    match tipo:
        TipoPieza.TRIANGULO_MEDIANO:
            return "TRIANGULO_MEDIANO"
        TipoPieza.TRIANGULO_PEQUENO:
            return "TRIANGULO_PEQUENO"
        TipoPieza.CUADRADO:
            return "CUADRADO"
        TipoPieza.PARALELOGRAMO:
            return "PARALELOGRAMO"
        TipoPieza.TRIANGULO_GRANDE:
            return "TRIANGULO_GRANDE"
    return "PIEZA DESCONOCIDA"
