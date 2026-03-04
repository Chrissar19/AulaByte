extends ActividadBase
class_name Actividad2

# Señales opcionales locales (por si quieres escucharlas desde el nivel u otra UI)
signal actividad_superada
signal actividad_fallida

@onready var lbl_ganar: Label = $UI/LblGanar
@onready var lbl_intentos: Label = $UI/LblIntentos
@onready var contenedor_objetos: Control = $ContenedorObjetos
@onready var contenedor_carpetas: Control = $ContenedorCarpetas
@onready var btn_salir: Button = $UI/BtnSalir
@onready var btn_ayuda: Button = $UI/BtnAyuda
@onready var audio_ayuda: AudioStreamPlayer = $AudioAyuda
@onready var lbl_tiempo: Label = $LblTiempo
@onready var timer_limite: Timer = $TimerLimite

@export var intentos: int = 5
@export var tiempo_mensaje: float = 2.0
@export var tiempo_maximo: float = 40.0

var _total_objetos: int = 0
var _objeto_correcto: int = 0
var _actividad_activa: bool = true
const MSJ_ORIGINAL := "Ordena los objetos"

func _ready() -> void:
	super._ready()
	
	btn_salir.pressed.connect(_on_btn_salir_pressed)
	
	lbl_ganar.text = MSJ_ORIGINAL
	lbl_ganar.scale = Vector2(1.0, 1.0)
	lbl_ganar.visible = true
	
	timer_limite.one_shot = true
	timer_limite.timeout.connect(_on_tiempo_agotado)
	
	_conectar_carpetas()
	_contar_objetos()
	_actualizar_intentos()
	
	reiniciar_tiempo()
	
func _process(_delta: float) -> void:
	if _actividad_activa and not timer_limite.is_stopped():
		var tiempo_restante = timer_limite.time_left
		lbl_tiempo.text = "Tiempo: %d" % ceil(tiempo_restante)
		
		# Feedback visual de urgencia
		if tiempo_restante < 5.0:
			lbl_tiempo.modulate = Color.RED
			if Engine.get_frames_drawn() % 30 < 15: # Efecto parpadeo simple
				lbl_tiempo.visible = true
			else:
				lbl_tiempo.visible = false
		else:
			lbl_tiempo.visible = true
			lbl_tiempo.modulate = Color.WHITE

func reiniciar_tiempo() -> void:
	timer_limite.start(tiempo_maximo)

func _on_tiempo_agotado() -> void:
	if not _finalizado:
		_actividad_activa = false
		_mostrar_feedback_temporal("¡Se acabó el tiempo!", Color.RED)
		_perder()

func _conectar_carpetas() -> void:
	for c in contenedor_carpetas.get_children():
		if c is Carpeta:
			c.soltar_item.connect(_soltar_item)


func _contar_objetos() -> void:
	_total_objetos = 0
	for c in contenedor_objetos.get_children():
		if c is ObjetoArrastrable:
			_total_objetos += 1


func _actualizar_intentos() -> void:
	if lbl_intentos:
		lbl_intentos.text = "Intentos: %d" % intentos


func _soltar_item(correct: bool) -> void:
	# Si la actividad ya terminó (éxito o fracaso), ignoramos más eventos
	if _finalizado:
		return

	if correct:
		_objeto_correcto += 1
		_mostrar_feedback_temporal("¡Bien hecho!", Color.GREEN)
		if _objeto_correcto >= _total_objetos:
			_ganar()
	else:
		intentos -= 1
		_mostrar_feedback_temporal("¡Ups, sigue intentando!", Color.RED)
		_actualizar_intentos()
		if intentos <= 0:
			_perder()

func _mostrar_feedback_temporal(texto: String, color: Color) -> void:
	lbl_ganar.text = texto
	lbl_ganar.modulate = color
	
	await get_tree().create_timer(tiempo_mensaje).timeout
	
	if not _finalizado:
		lbl_ganar.text = MSJ_ORIGINAL
		lbl_ganar.modulate = Color.WHITE

func _ganar() -> void:
	if _finalizado: return
	_actividad_activa = false
	lbl_ganar.text = "¡Excelente! Actividad superada"
	lbl_ganar.modulate = Color.CYAN
	lbl_ganar.visible = true
	actividad_superada.emit()
	_bloquear_objetos_arrastrables()
	finalizar_exito()


func _perder() -> void:
	if _finalizado: return
	
	_actividad_activa = false
	
	if lbl_intentos:
		lbl_intentos.text = "¡Sin intentos!"
		lbl_intentos.modulate = Color.RED
	lbl_ganar.text = "Sé que podrás en la próxima"
	lbl_ganar.modulate = Color.ORANGE
	actividad_fallida.emit()
	lbl_ganar.scale = Vector2(0.85, 0.85)
	lbl_ganar.visible = true
	_bloquear_objetos_arrastrables()
	finalizar_fracaso()
	

func _bloquear_objetos_arrastrables() -> void:
	for c in contenedor_objetos.get_children():
		if c is ObjetoArrastrable and is_instance_valid(c):
			c.mouse_filter = Control.MOUSE_FILTER_IGNORE

# Permite que el GameManager / nivel configure intentos vía parámetros
func configurar_con_parametros(parametros: Dictionary) -> void:
	if parametros.has("intentos"):
		intentos = max(1, int(parametros["intentos"]))
		_actualizar_intentos()
		
	if parametros.has("tiempo"):
		tiempo_maximo = float(parametros["tiempo"])
		reiniciar_tiempo()
		
func _on_btn_salir_pressed() -> void:
	cancelar_actividad()

func _on_btn_ayuda_pressed() -> void:
	audio_ayuda.play()
	
