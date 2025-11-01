# Actividad6.gd (fix Godot 4.x)
extends ActividadBase
class_name Actividad6

@onready var silueta: TextureRect = $Silueta
@onready var piezas_root: Node = $Piezas
@onready var lbl_tiempo: Label = $UI/LblTiempo
@onready var t_nivel: Timer = $TimerNivel

@export var tiempo_segundos: int = 120
@export var textura_mascara: Texture2D
@export var paso_rot_deg: float = 15.0
@export var tolerancia_rot_deg: float = 8.0

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
        { "pos": Vector2(448, 112), "rot_deg": 90.0,   "used": false },
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
    _restantes = piezas_root.get_child_count()
    if textura_mascara:
        _img_mask = textura_mascara.get_image()  # ✅ sin lock()
    _actualizar_tiempo()
    
    #-- Cuenta regresiva
    t_nivel.one_shot = false
    t_nivel.wait_time = 1.0
    t_nivel.process_mode = Node.PROCESS_MODE_INHERIT
    t_nivel.timeout.connect(_tick)
    t_nivel.start()

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

func _rot_ok_against(rot_pieza_deg: float, rot_dest_deg: float) -> bool:
    # Valida rotación de la pieza contra la rotación destino del slot
    var delta: float = abs(wrapf(rot_pieza_deg - rot_dest_deg, -180.0, 180.0))
    if delta <= tolerancia_rot_deg:
        return true
    return false

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
    if not _rot_ok_against(pieza.rotation_degrees, rot_dest):
        return false

    # Fijar
    pieza.global_position = pos_dest
    pieza.rotation_degrees = rot_dest
    pieza.set_process_input(false)
    pieza.set_process_unhandled_input(false)
    pieza.set_physics_process(false)

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
