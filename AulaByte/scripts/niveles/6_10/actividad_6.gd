extends ActividadBase
class_name Actividad6

@onready var silueta: TextureRect = $Silueta
@onready var piezas_root: Node = $Piezas
@onready var lbl_tiempo: Label = $UI/LblTiempo
@onready var t_nivel: Timer = $TimerNivel

@onready var mascara_debug: TextureRect

@export var tiempo_segundos: int = 120
@export var textura_mascara: Texture2D
@export var paso_rot_deg: float = 15.0
@export var tolerancia_rot_deg: float = 8.0

@export var mascara_dg: bool:
    set(value):
        mascara_dg = value
        _actualizar_visibilidad_mascara()
        
var _img_mask: Image
var _restantes: int

@export var color_a_destino: Dictionary = {
    # Triángulos grandes (2 slots)
    Color(1.0, 0.0, 0.0, 1.0): [
        { "pos": Vector2(448, 137), "rot_deg": 90.0,  "used": false },
        { "pos": Vector2(448, 184), "rot_deg": 270.0, "used": false },
    ],
    # Triángulo mediano (1 slot)
    Color(0.0, 1.0, 0.0, 1.0): [
        { "pos": Vector2(454, 105), "rot_deg": 90.0,   "used": false },
    ],
    # Triángulos pequeños (2 slots)
    Color(0.0, 0.0, 1.0, 1.0): [
        { "pos": Vector2(448, 77), "rot_deg": 270.0,   "used": false },
        { "pos": Vector2(412, 232), "rot_deg": 0.0,  "used": false },
    ],
    # Cuadrado (1 slot)
    Color(1, 1, 0): [
        { "pos": Vector2(424, 209), "rot_deg": 45.0,   "used": false },
    ],
    # Paralelogramo (1 slot)
    Color(1, 0, 1): [
        { "pos": Vector2(483, 219), "rot_deg": 270.0, "used": false },
    ],
}

func _ready() -> void:
    super._ready()
    add_to_group("Actividad6")
    
    _crear_mascara_dbg()
    
    _restantes = piezas_root.get_child_count()
    if textura_mascara:
        _img_mask = textura_mascara.get_image()
    _actualizar_tiempo()
    
    #-- Cuenta regresiva
    t_nivel.one_shot = false
    t_nivel.wait_time = 1.0
    t_nivel.process_mode = Node.PROCESS_MODE_INHERIT
    t_nivel.timeout.connect(_tick)
    t_nivel.start()
    
func _crear_mascara_dbg() -> void:
    mascara_debug = TextureRect.new()
    mascara_debug.name = "MascaraDebug"
    mascara_debug.texture = textura_mascara
    mascara_debug.size = silueta.size
    mascara_debug.position = silueta.position
    mascara_debug.mouse_filter = Control.MOUSE_FILTER_IGNORE
    mascara_debug.modulate = Color(1, 1, 1, 0.5)
    mascara_debug.z_index = 2
    
    add_child(mascara_debug)
    _actualizar_visibilidad_mascara()
    
func _actualizar_visibilidad_mascara() -> void:
    if mascara_debug:
        mascara_debug.visible = mascara_dg

func _tick() -> void:
    tiempo_segundos -= 1
    _actualizar_tiempo()
    if tiempo_segundos <= 0:
        finalizar_fracaso()

func _actualizar_tiempo() -> void:
    if lbl_tiempo:
        lbl_tiempo.text = "Tiempo: %ds" % tiempo_segundos

# Llamado por la pieza al soltar
func intentar_colocar(pieza: Node2D, color_objetivo: Color) -> void:
    if _img_mask == null:
        return

    var uv: Vector2 = _global_to_mask_uv(pieza.global_position)
    if uv.x < 0.0 or uv.x > 1.0 or uv.y < 0.0 or uv.y > 1.0:
        return

    var w: int = _img_mask.get_width()
    var h: int = _img_mask.get_height()

    var px_x: int = int(round(uv.x * float(w - 1)))
    var px_y: int = int(round(uv.y * float(h - 1)))
    var c: Color = _img_mask.get_pixel(px_x, px_y)

    if _matches_color(c, color_objetivo):
        var colocado: bool = _snap_or_replace(pieza, color_objetivo)
        if colocado:
            _restantes -= 1
            if _restantes <= 0:
                finalizar_exito()

func _rot_ok_against(rot_pieza_deg: float, rot_dest_deg: float, color_objetivo: Color) -> bool:
    var period := _symmetry_period_for_color(color_objetivo)  # 90° cuadrado, 180° paralelogramo, 360° otros
    # Distancia angular mínima al conjunto de ángulos equivalentes (dest + k*period)
    var diff := fposmod((rot_pieza_deg - rot_dest_deg), period)
    diff = min(diff, period - diff)
    return diff <= tolerancia_rot_deg

    
func _symmetry_period_for_color(c: Color) -> float:
    if _cuadrado_color(c):
        return 90.0
    if _paralelogramo_color(c):
        return 180.0
    return 360.0
    
func _cuadrado_color(c: Color) -> bool:
    return _matches_color(c, Color(1.0, 1.0, 0.0, 1.0))
    
func _paralelogramo_color(c: Color) -> bool:
    return _matches_color(c, Color(1.0, 0.0, 1.0, 1.0))

func _matches_color(c1: Color, c2: Color) -> bool:
    var eps: float = 0.05
    if abs(c1.r - c2.r) <= eps and abs(c1.g - c2.g) <= eps and abs(c1.b - c2.b) <= eps:
        return true
    return false

func _snap_or_replace(pieza: Node2D, color_objetivo: Color) -> bool:
    if not color_a_destino.has(color_objetivo):
        return false

    var lista: Array = color_a_destino[color_objetivo]
    if lista.is_empty():
        return false

    # Slot libre más cercano
    var mejor_idx: int = -1
    var mejor_dist: float = INF
    var i: int = 0
    while i < lista.size():
        var slot: Dictionary = lista[i]
        var usado: bool = bool(slot.get("used", false))
        if not usado:
            var pos_slot: Vector2 = slot.get("pos", Vector2.ZERO)
            var dist: float = pieza.global_position.distance_to(pos_slot)
            if dist < mejor_dist:
                mejor_dist = dist
                mejor_idx = i
        i += 1

    if mejor_idx == -1:
        return false  # no hay slots libres para este color

    var elegido: Dictionary = lista[mejor_idx]
    var pos_dest: Vector2 = elegido.get("pos", Vector2.ZERO)
    var rot_dest: float = float(elegido.get("rot_deg", 0.0))

    # Validar rotación contra el destino
    if not _rot_ok_against(pieza.rotation_degrees, rot_dest, color_objetivo):
        return false

    # Fijar
    pieza.global_position = pos_dest
    pieza.rotation_degrees = rot_dest
    pieza.set_process_input(false)
    pieza.set_process_unhandled_input(false)
    pieza.set_physics_process(false)
    
    if pieza is CanvasItem:
        pieza.z_index = 0

    # Marcar slot ocupado
    elegido["used"] = true
    lista[mejor_idx] = elegido
    color_a_destino[color_objetivo] = lista

    return true


func _global_to_mask_uv(gpos: Vector2) -> Vector2:
    # Convierte posición global (de la pieza) a posición local dentro del TextureRect
    var inv_transform: Transform2D = silueta.get_global_transform_with_canvas().affine_inverse()
    var lp: Vector2 = inv_transform * gpos
    var size: Vector2 = silueta.get_rect().size
    var uv: Vector2 = Vector2(lp.x / size.x, lp.y / size.y)
    return uv
    
    
func finalizar_exito() -> void:
    if is_instance_valid(t_nivel):
        t_nivel.stop()
    super.finalizar_exito()

func finalizar_fracaso() -> void:
    if is_instance_valid(t_nivel):
        t_nivel.stop()
    super.finalizar_fracaso()

func cancelar_actividad() -> void:
    if is_instance_valid(t_nivel):
        t_nivel.stop()
    super.cancelar_actividad()
