extends ActividadBase
class_name Actividad6

# --- Referencias UI ---
@onready var silueta: TextureRect = $Silueta
@onready var piezas_root: Node = $Piezas
@onready var btn_salir: Button = $UI/BtnSalir
@onready var aud_ayuda: AudioStreamPlayer = $AudAyuda
@onready var ctrl_tiempo: ControlTiempo = $UI/ControlTiempo

# --- Configuración del Puzzle ---
@export var tiempo_segundos: int = 120
@export var textura_mascara: Texture2D
@export var paso_rot_deg: float = 15.0
@export var tolerancia_rot_deg: float = 8.0

@export var mascara_dg: bool:
	set(value):
		mascara_dg = value
		_actualizar_visibilidad_mascara()

# --- Variables de Estado ---
var _img_mask: Image
var _restantes: int
var mascara_debug: TextureRect

@export var color_a_destino: Dictionary = {
	# Triángulos grandes (2 slots)
	Color(1.0, 0.0, 0.0, 1.0): [
		{ "pos": Vector2(448, 137), "rot_deg": 90.0,  "used": false },
		{ "pos": Vector2(448, 184), "rot_deg": 270.0, "used": false },
	],
	# Triángulo mediano (1 slot)
	Color(0.0, 1.0, 0.0, 1.0): [
		{ "pos": Vector2(454, 105), "rot_deg": 90.0,    "used": false },
	],
	# Triángulos pequeños (2 slots)
	Color(0.0, 0.0, 1.0, 1.0): [
		{ "pos": Vector2(448, 77), "rot_deg": 270.0,    "used": false },
		{ "pos": Vector2(412, 232), "rot_deg": 0.0,  "used": false },
	],
	# Cuadrado (1 slot)
	Color(1, 1, 0): [
		{ "pos": Vector2(424, 209), "rot_deg": 45.0,    "used": false },
	],
	# Paralelogramo (1 slot)
	Color(1, 0, 1): [
		{ "pos": Vector2(483, 219), "rot_deg": 270.0, "used": false },
	],
}

func _ready() -> void:
	super._ready()
	add_to_group("Actividad6")
	
	# Tiempo
	ctrl_tiempo.vincular_ui(null, btn_salir, func(h): habilitar_esc = h)
	ctrl_tiempo.tiempo_agotado.connect(_on_tiempo_agotado)
	ctrl_tiempo.iniciar(tiempo_segundos)
	
	_crear_mascara_dbg()
	
	_restantes = piezas_root.get_child_count()
	if textura_mascara:
		_img_mask = textura_mascara.get_image()
	
	btn_salir.pressed.connect(_on_salir_pressed)

# --- Lógica del Juego (Tangram) ---
func intentar_colocar(pieza: Node2D, color_objetivo: Color) -> void:
	if _img_mask == null or _finalizado: return

	var uv: Vector2 = _global_to_mask_uv(pieza.global_position)
	if uv.x < 0.0 or uv.x > 1.0 or uv.y < 0.0 or uv.y > 1.0: return

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
				_ganar()

func _snap_or_replace(pieza: Node2D, color_objetivo: Color) -> bool:
	if not color_a_destino.has(color_objetivo): return false
	var lista: Array = color_a_destino[color_objetivo]
	
	var mejor_idx: int = -1
	var mejor_dist: float = INF
	
	for i in range(lista.size()):
		var slot = lista[i]
		if not slot.get("used", false):
			var dist = pieza.global_position.distance_to(slot.get("pos"))
			if dist < mejor_dist:
				mejor_dist = dist
				mejor_idx = i

	if mejor_idx == -1: return false

	var elegido = lista[mejor_idx]
	if not _rot_ok_against(pieza.rotation_degrees, elegido.get("rot_deg"), color_objetivo):
		return false

	# Fijar pieza
	pieza.global_position = elegido.get("pos")
	pieza.rotation_degrees = elegido.get("rot_deg")
	pieza.set_process_input(false)
	pieza.z_index = 0

	# Marcar ocupado
	elegido["used"] = true
	return true

# --- Finalización ---
func _ganar():
	ctrl_tiempo.detener()
	finalizar_exito()

func _on_tiempo_agotado():
	finalizar_fracaso()

func _on_salir_pressed():
	ctrl_tiempo.detener()
	cancelar_actividad()

func _on_btn_ayuda_pressed() -> void:
	if aud_ayuda.playing: return
	
	ctrl_tiempo.pausar(true)
	aud_ayuda.play()
	await aud_ayuda.finished
	if not _finalizado:
		ctrl_tiempo.pausar(false)

# --- Métodos Matemáticos ---
func _global_to_mask_uv(gpos: Vector2) -> Vector2:
	var inv_transform: Transform2D = silueta.get_global_transform_with_canvas().affine_inverse()
	var lp: Vector2 = inv_transform * gpos
	var size: Vector2 = silueta.get_rect().size
	return Vector2(lp.x / size.x, lp.y / size.y)

func _matches_color(c1: Color, c2: Color) -> bool:
	var eps: float = 0.05
	return abs(c1.r - c2.r) <= eps and abs(c1.g - c2.g) <= eps and abs(c1.b - c2.b) <= eps

func _rot_ok_against(rot_p: float, rot_d: float, color: Color) -> bool:
	var period := _symmetry_period_for_color(color)
	var diff := fposmod((rot_p - rot_d), period)
	diff = min(diff, period - diff)
	return diff <= tolerancia_rot_deg

func _symmetry_period_for_color(c: Color) -> float:
	if _matches_color(c, Color(1, 1, 0)): return 90.0 # Cuadrado
	if _matches_color(c, Color(1, 0, 1)): return 180.0 # Paralelogramo
	return 360.0

func _crear_mascara_dbg() -> void:
	mascara_debug = TextureRect.new()
	mascara_debug.texture = textura_mascara
	mascara_debug.size = silueta.size
	mascara_debug.position = silueta.position
	mascara_debug.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mascara_debug.modulate = Color(1, 1, 1, 0.5)
	add_child(mascara_debug)
	_actualizar_visibilidad_mascara()

func _actualizar_visibilidad_mascara() -> void:
	if mascara_debug: mascara_debug.visible = mascara_dg
