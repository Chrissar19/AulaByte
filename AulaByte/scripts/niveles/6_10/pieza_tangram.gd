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

var en_posicion_correcta: bool = false
var sensor_actual: Area2D = null




func verificar_posicion():
    if not sensor_actual:
        en_posicion_correcta = false
        actualizar_visual()
        return
        
    #-- Verificar rotacion
    var rotacion_esperada = sensor_actual.get_meta("rotacion_esperada", 0.0)
    var tolerancia_rotacion = sensor_actual.get_meta("tolerancia_rotacion", 15.0)
    
    var diferencia_rot = abs(normalizar_angulo(rotation_degrees) - normalizar_angulo(rotacion_esperada))
    if diferencia_rot > 180:
        diferencia_rot = 360 - diferencia_rot
        
    en_posicion_correcta = diferencia_rot <= tolerancia_rotacion
    actualizar_visual()


func normalizar_angulo(angulo: float) -> float:
    angulo = fmod(angulo, 360.0)
    if angulo < 0:
        angulo += 360.0
    return angulo


func actualizar_visual():
    if en_posicion_correcta:
        modulate = Color(1.0, 1.0, 1.0, 1.0)
    else:
        modulate = Color(1.0, 1.0, 1.0, 0.9)


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
