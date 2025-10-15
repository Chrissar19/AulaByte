extends ActividadBase
class_name Actividad6

# Contenedor de todas las piezas del tangram
@onready var contenedor_piezas: Node = $Contenedor_piezas

# Variables para controlar el arrastre
var pieza_arrastrando: Node = null
var offset = Vector2.ZERO
var piezas: Array[Node] = []

func _ready():
    super._ready()  # Llamar al _ready del padre
    
    # Obtener todas las piezas hijas del contenedor
    if contenedor_piezas:
        for hijo in contenedor_piezas.get_children():
            if hijo is Sprite2D or hijo is TextureRect or hijo is Control:
                piezas.append(hijo)
    
    set_process_input(true)

func _input(event):
    # No procesar input si la actividad ya finalizó
    if _finalizado:
        return
    
    # Detectar clic del mouse
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            if event.pressed:
                # Buscar qué pieza fue clickeada (de arriba hacia abajo en el z-index)
                var pieza_clickeada = obtener_pieza_bajo_mouse(event.position)
                if pieza_clickeada:
                    pieza_arrastrando = pieza_clickeada
                    # Traer la pieza al frente
                    mover_al_frente(pieza_arrastrando)
                    # Guardar el offset
                    offset = pieza_arrastrando.position - event.position
            else:
                # Soltar la pieza
                if pieza_arrastrando:
                    pieza_arrastrando = null
                    # Verificar si se completó el tangram
                    verificar_completado()
        
        # Rotar con la rueda del mouse
        elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
            var pieza = obtener_pieza_bajo_mouse(event.position)
            if pieza:
                rotar_pieza(pieza, 15)  # Rotar 15 grados en sentido horario
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            var pieza = obtener_pieza_bajo_mouse(event.position)
            if pieza:
                rotar_pieza(pieza, -15)  # Rotar 15 grados en sentido antihorario
    
    # Mover la pieza mientras se arrastra
    if event is InputEventMouseMotion and pieza_arrastrando:
        pieza_arrastrando.position = event.position + offset

func obtener_pieza_bajo_mouse(mouse_pos: Vector2) -> Node:
    # Recorrer las piezas en orden inverso (las de arriba primero)
    for i in range(piezas.size() - 1, -1, -1):
        var pieza = piezas[i]
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
            # Convertir la posición del mouse al espacio local del sprite (considerando rotación)
            var local_mouse_pos = sprite.to_local(mouse_pos)
            var rect = sprite.get_rect()
            # Centrar el rectángulo en el origen (0,0)
            rect.position = -sprite.texture.get_size() / 2
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

func rotar_pieza(pieza: Node, grados: float):
    # Convertir grados a radianes y aplicar rotación
    if pieza is Node2D:
        var node2d := pieza as Node2D
        node2d.rotation_degrees += grados
    elif pieza is Control:
        var control := pieza as Control
        control.rotation_degrees += grados

func mover_al_frente(pieza: Node):
    # Mover la pieza al final del array (se dibuja encima)
    if pieza in piezas:
        piezas.erase(pieza)
        piezas.append(pieza)
        # Cambiar el z-index si es Node2D
        if pieza is Node2D:
            var node2d := pieza as Node2D
            node2d.z_index = piezas.size()

func verificar_completado():
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
    
    pass

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
