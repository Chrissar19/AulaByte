extends ActividadBase
class_name Actividad3

# --- Señales ---
signal actividad_superada
signal actividad_fallida

# --- Referencias UI ---
@onready var salida_texto: Label = $UI/LblGanar # Cambiado p/ consistencia
@onready var lbl_intentos: Label = $UI/LblIntentos
@onready var teclado_zona: TecladoZona = $TecladoZona
@onready var contenedor_objetos: Control = $ContenedorObjetos
@onready var btn_salir: Button = $UI/BtnSalir
@onready var btn_ayuda: Button = $UI/BtnAyuda
@onready var audio_ayuda: AudioStreamPlayer = $AudioAyuda
@onready var ctrl_tiempo: ControlTiempo = $UI/ControlTiempo # El componente maestro

# --- Configuración y Estado ---
@export var intentos: int = 5
@export var tiempo_maximo: float = 60.0
const MSJ_ORIGINAL := "¡Cada cosa en su lugar!"

var _total_objetos := 0
var _aciertos := 0

# --- Ciclo de Vida ---
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
	_contar_objetos()
	teclado_zona.soltar_item.connect(_on_item_dropped)
	
	# Conectar Botones
	btn_salir.pressed.connect(_on_salir_pressed)
	if btn_ayuda: btn_ayuda.pressed.connect(_on_ayuda_pressed)

# --- Lógica de Juego ---
func _contar_objetos() -> void:
	_total_objetos = 0
	for c in contenedor_objetos.get_children():
		if c is TeclaArrastrable:
			_total_objetos += 1

func _on_item_dropped(correcto: bool) -> void:
	if _finalizado: return
	
	if correcto:
		_aciertos += 1
		var frases_bien = ["¡Correcto!", "¡Eres muy bueno!", "¡Eres un genio!"]
		_mostrar_mensaje_temporal(frases_bien.pick_random(), 1.5, Color.GREEN)
		
		if _aciertos >= _total_objetos:
			_ganar()
	else:
		_manejar_error()

func _manejar_error():
	intentos -= 1
	if lbl_intentos:
		lbl_intentos.text = "Intentos: %d" % intentos
	
	if intentos <= 0:
		_perder("¡Sin intentos!")
	else:
		var frases_mal = ["¡Inténtalo nuevamente!", "¡Vamos, tú puedes!", "De los errores aprendemos"]
		_mostrar_mensaje_temporal(frases_mal.pick_random(), 1.5, Color.RED)

# --- Finalización ---
func _ganar() -> void:
	ctrl_tiempo.detener()
	salida_texto.text = "¡Excelente! Teclado completado"
	salida_texto.modulate = Color.CYAN
	_bloquear_teclas()
	actividad_superada.emit()
	finalizar_exito()

func _perder(razon: String) -> void:
	ctrl_tiempo.detener()
	if lbl_intentos:
		lbl_intentos.text = razon
		lbl_intentos.modulate = Color.RED
	
	salida_texto.text = "Sé que podrás en la próxima"
	salida_texto.modulate = Color.ORANGE
	salida_texto.scale = Vector2(0.85, 0.85) 
	_bloquear_teclas()
	actividad_fallida.emit()
	finalizar_fracaso()

func _bloquear_teclas() -> void:
	for c in contenedor_objetos.get_children():
		if c is TeclaArrastrable:
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
