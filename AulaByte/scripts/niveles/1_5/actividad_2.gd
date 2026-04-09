extends ActividadBase
class_name Actividad2

# --- Señales ---
signal actividad_superada
signal actividad_fallida

# --- Referencias UI ---
@onready var salida_texto: Label = $UI/LblGanar # Cambiamos nombre p/ consistencia
@onready var lbl_intentos: Label = $UI/LblIntentos
@onready var contenedor_objetos: Control = $ContenedorObjetos
@onready var contenedor_carpetas: Control = $ContenedorCarpetas
@onready var btn_salir: Button = $UI/BtnSalir
@onready var btn_ayuda: Button = $UI/BtnAyuda
@onready var audio_ayuda: AudioStreamPlayer = $AudioAyuda
@onready var ctrl_tiempo: ControlTiempo = $UI/ControlTiempo # El componente maestro

# --- Configuración y Estado ---
@export var intentos: int = 5
@export var tiempo_maximo: float = 40.0
const MSJ_ORIGINAL := "Ordena los objetos"

var _total_objetos: int = 0
var _objeto_correcto: int = 0

# ===============================================================
# INICIALIZACIÓN Y CONFIGURACIÓN
# ====================================================================
func _ready() -> void:
	super._ready()
	
	# Configuración UI inicial
	salida_texto.text = MSJ_ORIGINAL
	if lbl_intentos: lbl_intentos.text = "Intentos: %d" % intentos
	
	# VINCULAR COMPONENTE DE TIEMPO
	ctrl_tiempo.vincular_ui(salida_texto, btn_salir, func(h): habilitar_esc = h)
	ctrl_tiempo.tiempo_agotado.connect(_on_tiempo_agotado)
	ctrl_tiempo.iniciar(tiempo_maximo)
	
	# Preparar Mecánicas
	_conectar_carpetas()
	_contar_objetos()
	
	# Conectar Botones
	btn_salir.pressed.connect(_on_salir_pressed)
	if btn_ayuda: btn_ayuda.pressed.connect(_on_ayuda_pressed)

# --- Lógica de Juego ---
func _conectar_carpetas() -> void:
	for c in contenedor_carpetas.get_children():
		if c.has_signal("soltar_item"):
			c.soltar_item.connect(_soltar_item)

func _contar_objetos() -> void:
	_total_objetos = 0
	for c in contenedor_objetos.get_children():
		if c is ObjetoArrastrable:
			_total_objetos += 1

func _soltar_item(correct: bool) -> void:
	if _finalizado: return

	if correct:
		_objeto_correcto += 1
		_mostrar_mensaje_temporal("¡Bien hecho!", 1.5, Color.GREEN)
		
		if _objeto_correcto >= _total_objetos:
			_ganar()
	else:
		_manejar_error()

func _manejar_error():
	intentos -= 1
	if lbl_intentos: lbl_intentos.text = "Intentos: %d" % intentos
	
	if intentos <= 0:
		_perder("¡Sin intentos!")
	else:
		_mostrar_mensaje_temporal("¡Ups, sigue intentando!", 1.5, Color.RED)

# --- Finalización ---
func _ganar() -> void:
	ctrl_tiempo.detener()
	salida_texto.text = "¡Excelente! Actividad superada"
	salida_texto.modulate = Color.CYAN
	actividad_superada.emit()
	_bloquear_objetos_arrastrables()
	finalizar_exito()

func _perder(razon: String) -> void:
	ctrl_tiempo.detener()
	if lbl_intentos:
		lbl_intentos.text = razon
		lbl_intentos.modulate = Color.RED
	
	salida_texto.scale = Vector2(0.8,0.8)
	salida_texto.text = "Sé que podrás en la próxima"
	salida_texto.modulate = Color.ORANGE
	actividad_fallida.emit()
	_bloquear_objetos_arrastrables()
	finalizar_fracaso()

func _bloquear_objetos_arrastrables() -> void:
	for c in contenedor_objetos.get_children():
		if c.has_method("set_mouse_filter"):
			c.mouse_filter = Control.MOUSE_FILTER_IGNORE

func configurar_con_parametros(parametros: Dictionary) -> void:
	if parametros.has("intentos"):
		intentos = max(1, int(parametros["intentos"]))
		if lbl_intentos: lbl_intentos.text = "Intentos: %d" % intentos
		
	if parametros.has("tiempo"):
		tiempo_maximo = float(parametros["tiempo"])
		ctrl_tiempo.iniciar(tiempo_maximo)

func _mostrar_mensaje_temporal(nuevo_texto: String, duracion: float, color: Color) -> void:
	if salida_texto:
		var color_orig = salida_texto.modulate
		salida_texto.text = nuevo_texto
		salida_texto.modulate = color
		await get_tree().create_timer(duracion).timeout
		if not _finalizado and salida_texto:
			salida_texto.text = MSJ_ORIGINAL
			salida_texto.modulate = color_orig

func _on_tiempo_agotado() -> void:
	_perder("¡Se acabó el tiempo!")

func _on_salir_pressed() -> void:
	cancelar_actividad()

func _on_ayuda_pressed() -> void:
	if audio_ayuda: audio_ayuda.play()
