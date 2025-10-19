extends ActividadBase
class_name Actividad6

# Contenedor de todas las piezas del tangram
@onready var contenedor_piezas: Node = $Contenedor_piezas

# Variables para controlar el arrastre
var pieza_arrastrando: Node = null
var offset = Vector2.ZERO
var piezas: Array[Node] = []
const GRADOS_ROTACION := 15.0
const MAX_ROTACION: int = 24 #-- 360 / 15

func _ready():
    super._ready()  # Llamar al _ready del padre
    
    # Obtener todas las piezas hijas del contenedor
    if contenedor_piezas:
        for hijo in contenedor_piezas.get_children():
            if hijo is Sprite2D or hijo is TextureRect or hijo is Control:
                piezas.append(hijo)
                if hijo is PiezaTangram:
                    hijo.init_rotation_steps()
    set_process_input(true)

func _input(event):
    # No procesar input si la actividad ya finalizó
    if _finalizado:
        return
    
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            if event.pressed:
                var pieza_clickeada = obtener_pieza_bajo_mouse(event.position)
                if pieza_clickeada:
                    pieza_arrastrando = pieza_clickeada
                    mover_al_frente(pieza_arrastrando)
                    offset = pieza_arrastrando.position - event.position
            else:
                # Al soltar
                if pieza_arrastrando:
                    if pieza_arrastrando.has_method("verificar_posicion"):
                        pieza_arrastrando.verificar_posicion()
                        if pieza_arrastrando is PiezaTangram and pieza_arrastrando.locked:
                            piezas.erase(pieza_arrastrando)
                            pieza_arrastrando = null
                            verificar_completado()
                            return
                    pieza_arrastrando = null
                    verificar_completado()
                    
        elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
            var pieza = obtener_pieza_bajo_mouse(event.position)
            if pieza and pieza is PiezaTangram and not pieza.locked:
                rotar_pieza(pieza, 1)  # +1 step (15 grados horario)
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            var pieza = obtener_pieza_bajo_mouse(event.position)
            if pieza and pieza is PiezaTangram and not pieza.locked:
                rotar_pieza(pieza, -1)  # -1 step (15 grados antihorario)

    if event is InputEventMouseMotion and pieza_arrastrando:
        if pieza_arrastrando is PiezaTangram and pieza_arrastrando.locked:
            pieza_arrastrando = null
            return
        pieza_arrastrando.position = event.position + offset

func obtener_pieza_bajo_mouse(mouse_pos: Vector2) -> Node:
    # Recorrer las piezas en orden inverso (las de arriba primero)
    for i in range(piezas.size() - 1, -1, -1):
        var pieza = piezas[i]
        # Ignorar si la pieza ya está bloqueada
        if pieza is PiezaTangram and pieza.locked:
            continue
        if esta_sobre_pieza(pieza, mouse_pos):
            return pieza
    return null

func esta_sobre_pieza(pieza: Node, mouse_pos: Vector2) -> bool:
    if not pieza:
        return false
    
    # Para Sprite2D y Node2D
    if pieza is Sprite2D:
        var sprite := pieza as Sprite2D
        if sprite.texture:
            var local_mouse_pos = sprite.to_local(mouse_pos)
            var rect = sprite.get_rect()
            rect.position = -sprite.texture.get_size() / 2  # Asume centered=true
            return rect.has_point(local_mouse_pos)
        return false
    
    # Para TextureRect
    if pieza is TextureRect:
        var tex_rect := pieza as TextureRect
        return tex_rect.get_global_rect().has_point(mouse_pos)
    
    # Para Control genérico
    if pieza is Control:
        var control := pieza as Control
        return control.get_global_rect().has_point(mouse_pos)
    
    return false

func rotar_pieza(pieza: Node, steps_delta: int):
    if pieza is PiezaTangram:
        var tangram := pieza as PiezaTangram
        tangram.rotar_pieza = (tangram.rotar_pieza + steps_delta) % MAX_ROTACION
        if tangram.rotation_steps < 0:
            tangram.rotation_steps += MAX_ROTACION
        tangram.rotation_degrees = tangram.rotation_steps * GRADOS_ROTACION
        print("Rotación steps: ", tangram.rotation_steps, " -> grados: ", tangram.rotation_degrees)  # Debug
        

func mover_al_frente(pieza: Node):
    if pieza in piezas:
        piezas.erase(pieza)
        piezas.append(pieza)
        if pieza is Node2D:
            pieza.z_index = piezas.size()

func verificar_completado():
    var todas_locked = true
    for pieza in contenedor_piezas.get_children():
        if pieza is PiezaTangram and not pieza.locked:
            todas_locked = false
            break
    if todas_locked:
        finalizar_exito()
    # Aquí implementas tu lógica de verificación
    # Por ejemplo, verificar si todas las piezas están en sus posiciones objetivo
    
    # Ejemplo básico: verificar si cada pieza está cerca de su posición objetivo
    # var todas_correctas = true
    # for i in piezas.size():
    #     var pieza = piezas[i]
    #     var posicion_objetivo = posiciones_objetivo[i]
    #     if pieza.position.distance_to(posicion_objetivo) > 20:
    #         todas_correctas = false
    #         break
    #
    # if todas_correctas:
    #     finalizar_exito()
    

# Sobrescribir si necesitas configuración personalizada
func configurar_con_parametros(parametros: Dictionary) -> void:
    super.configurar_con_parametros(parametros)
    # Ejemplo: 
    # if parametros.has("posiciones_iniciales"):
    #     var posiciones = parametros["posiciones_iniciales"]
    #     for i in min(piezas.size(), posiciones.size()):
    #         piezas[i].position = posiciones[i]

# Sobrescribir para limpiar recursos
func limpiar() -> void:
    super.limpiar()
    pieza_arrastrando = null
    piezas.clear()
