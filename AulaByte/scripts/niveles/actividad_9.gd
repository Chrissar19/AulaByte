extends ActividadBase
class_name Actividad9

# --- Referencias UI ---
@onready var btn_salir: Button = $UI/BtnSalir
@onready var btn_pista: Button = $UI/BtnPista
@onready var audio_pista: AudioStreamPlayer = $AudioPista
@onready var ctrl_tiempo: ControlTiempo = $UI/ControlTiempo
@onready var lbl_intentos: Label = $UI/LblIntentos
@onready var descripcion_act: Label = $"UI/descripcion act"

# --- Referencias de Objetos ---
@onready var contenedor_objetos: Control = $ZonaJuego/ContenedorObjetos

# --- Configuración y Estado ---
@export var tiempo_maximo: float = 120.0 
@export var intentos: int = 3

const MSJ_ORIGINAL := "Clasifica los componentes en\nsus zonas correspondientes."

var zonas_correctas: Dictionary = {
	"texto": ["ArchivosDigitales"],
	"teclado": ["ElementoEntrada"],
	"raton": ["ElementoEntrada"],
	"microfono": ["ElementoEntrada"],
	"disco_duro": ["ComponentesInternos", "PartesComputador"],
	"imagen": ["ArchivosDigitales"],
	"imagen_2": ["ArchivosDigitales"],
	"video": ["ArchivosDigitales"],
	"video_2": ["ArchivosDigitales"],
	"ram": ["ComponentesInternos", "PartesComputador"],
	"procesador": ["ComponentesInternos", "PartesComputador"],
	"impresora": ["ElementoSalida"],
	"audifonos": ["ElementoSalida"]
}

var asignaciones: Dictionary = {}

# --- Ciclo de Vida ---
func _ready() -> void:
	super._ready()
	
	descripcion_act.text = MSJ_ORIGINAL
	lbl_intentos.text = "Intentos: %d" % intentos
	
	ctrl_tiempo.vincular_ui(descripcion_act, btn_salir, func(h): habilitar_esc = h)
	ctrl_tiempo.tiempo_agotado.connect(_on_tiempo_agotado)
	ctrl_tiempo.iniciar(tiempo_maximo)
	
	btn_salir.pressed.connect(_on_salir_pressed)
	if btn_pista:
		btn_pista.pressed.connect(_on_btn_pista_pressed)
	
	_conectar_senales_objetos()

func _conectar_senales_objetos() -> void:
	for obj in contenedor_objetos.get_children():
		if obj.has_signal("element_asigned"):
			# Conectamos la señal que ahora recibe el clon
			obj.element_asigned.connect(_on_any_element_asigned.bind(obj.name.to_lower(), obj))

# --- Lógica de Juego ---
func _on_any_element_asigned(categorias: Array, zona: String, clon: Node, element_name: String, obj_ref: Node) -> void:
	if _finalizado: return
	
	var clave_busqueda = element_name
	for k in zonas_correctas.keys():
		if k.replace("_", "") == element_name.replace("_", ""):
			clave_busqueda = k
			break

	if not zonas_correctas.has(clave_busqueda): return

	var zonas_validas: Array = zonas_correctas[clave_busqueda]
	
	# --- VALIDACIÓN DE ERROR ---
	if not zona in zonas_validas:
		_manejar_error_clasificacion()
		if is_instance_valid(clon):
			clon.queue_free() # Borra el clon intruso
		return
	
	# --- VALIDACIÓN DE ÉXITO ---
	if not asignaciones.has(clave_busqueda):
		asignaciones[clave_busqueda] = []
		
	if zona in asignaciones[clave_busqueda]:
		return
		
	asignaciones[clave_busqueda].append(zona)
	
	if _asignacion_completa(clave_busqueda):
		if obj_ref.has_method("ocultar_elemento"):
			obj_ref.ocultar_elemento()
			
	if _todas_asignaciones_correctas():
		_ganar()

func _manejar_error_clasificacion() -> void:
	intentos -= 1
	lbl_intentos.text = "Intentos: %d" % intentos
	
	if intentos <= 0:
		_perder()
	else:
		_mostrar_mensaje_temporal("¡Zona incorrecta!", 2.0, Color.TOMATO)

func _asignacion_completa(element: String) -> bool:
	if not asignaciones.has(element): return false
	return asignaciones[element].size() == zonas_correctas[element].size()

func _todas_asignaciones_correctas() -> bool:
	if asignaciones.size() < zonas_correctas.size(): return false
	for element in zonas_correctas.keys():
		if not _asignacion_completa(element): return false
	return true

# --- Finalización ---
func _ganar() -> void:
	ctrl_tiempo.detener()
	descripcion_act.text = "¡Excelente clasificación!"
	descripcion_act.modulate = Color.CYAN
	finalizar_exito()

func _perder() -> void:
	ctrl_tiempo.detener()
	lbl_intentos.text = "¡Sin intentos!"
	lbl_intentos.modulate = Color.RED
	finalizar_fracaso()

func _on_tiempo_agotado() -> void:
	_perder()

func _mostrar_mensaje_temporal(nuevo_texto: String, duracion: float, color: Color) -> void:
	if descripcion_act:
		var color_original = descripcion_act.modulate
		descripcion_act.text = nuevo_texto
		descripcion_act.modulate = color
		await get_tree().create_timer(duracion).timeout
		if not _finalizado and descripcion_act:
			descripcion_act.text = MSJ_ORIGINAL
			descripcion_act.modulate = color_original

func _on_salir_pressed():
	ctrl_tiempo.detener()
	cancelar_actividad()

func _on_btn_pista_pressed():
	if audio_pista and not audio_pista.playing:
		ctrl_tiempo.pausar(true)
		audio_pista.play()
		await audio_pista.finished
		if not _finalizado: ctrl_tiempo.pausar(false)

func configurar_con_parametros(parametros: Dictionary) -> void:
	if parametros.has("intentos"):
		intentos = int(parametros["intentos"])
		lbl_intentos.text = "Intentos: %d" % intentos
	if parametros.has("tiempo"):
		tiempo_maximo = float(parametros["tiempo"])
		ctrl_tiempo.init_tiempo(tiempo_maximo)
