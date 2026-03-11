extends ActividadBase
class_name Actividad5

# --- Referencias UI ---
@onready var lbl_texto: Label = $UI/LblTexto
@onready var btn_salir: Button = $UI/BtnSalir
@onready var btn_aceptar: Button = $UI/BtnAceptar
@onready var zona_cartas: Control = $Fondo/ZonaCartas
@onready var btn_reiniciar: Button = $UI/BtnReiniciar

@onready var sonido: CartaVolteable = $Fondo/ZonaCartas/sonido
@onready var escribir: CartaVolteable = $Fondo/ZonaCartas/escribir
@onready var mover_raton: CartaVolteable = $Fondo/ZonaCartas/mover_raton

@onready var contenedor_imagen: Control = $Fondo/GeneraCartaAleatoria
@onready var imagen_aleatoria: TextureRect = $Fondo/GeneraCartaAleatoria/ImagenAleatoria
@onready var voz_guia: AudioStreamPlayer = $VozGuia
@onready var ctrl_tiempo: ControlTiempo = $UI/ControlTiempo # El componente maestro

# --- Configuración y Estado ---
const IMAGENES := [
	{ "ruta": "res://recursos/imagenes/niveles/nivel5/actividad5/raton.png", "tipo": "mover_raton" },
	{ "ruta": "res://recursos/imagenes/niveles/nivel5/actividad5/teclado.png", "tipo": "escribir" },
	{ "ruta": "res://recursos/imagenes/niveles/nivel5/actividad5/microfono.png", "tipo": "sonido" }
]

var _cartas: Array = []
var _imagen_actual: Dictionary
@export var tiempo_maximo: float = 15.0 # Un poco más rápido para este nivel

#-----------------------------------------------------------
#-- CICLO DE VIDA
#-----------------------------------------------------------
func _ready() -> void:
	super._ready()
	
	# 1. Vinculación del Componente de Tiempo
	# Usamos la barra vertical si la configuraste así en el editor
	ctrl_tiempo.vincular_ui(lbl_texto, btn_salir, func(h): habilitar_esc = h)
	ctrl_tiempo.tiempo_agotado.connect(_al_morir_por_tiempo)
	
	# 2. Conexión de Botones
	btn_salir.pressed.connect(_on_salir_pressed)
	btn_reiniciar.pressed.connect(_on_reiniciar_pressed)
	# Nota: btn_aceptar no parece tener lógica de confirmación manual, 
	# la validación ocurre al tocar la carta.
	
	# 3. Conexión de Cartas
	mover_raton.carta_seleccionada.connect(_on_carta_seleccionada)
	escribir.carta_seleccionada.connect(_on_carta_seleccionada)
	sonido.carta_seleccionada.connect(_on_carta_seleccionada)

	_iniciar_secuencia()

#-----------------------------------------------------------
#-- LÓGICA DE SECUENCIA
#-----------------------------------------------------------
func _iniciar_secuencia() -> void:
	ctrl_tiempo.detener() # Paramos por si venimos de un reinicio
	lbl_texto.text = "Selecciona la carta correcta según la imagen."
	lbl_texto.modulate = Color.WHITE
	
	btn_aceptar.disabled = true
	_cargar_imagen_aleatoria()
	_reunir_cartas()
	
	# Iniciamos el tiempo
	ctrl_tiempo.iniciar(tiempo_maximo)

func _cargar_imagen_aleatoria() -> void:
	_imagen_actual = IMAGENES.pick_random() # Usamos pick_random() que es más limpio
	var textura := load(_imagen_actual["ruta"])
	if textura:
		imagen_aleatoria.texture = textura
		# (Mantenemos tu lógica de centrado y tamaño)
		imagen_aleatoria.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED 
	else:
		push_warning("No se pudo cargar la imagen: " + _imagen_actual["ruta"])

func _reunir_cartas() -> void:
	_cartas.clear()
	for n in zona_cartas.get_children():
		if n is CartaVolteable:
			n.forzar_cierre()
			_cartas.append(n)

#------------------------------------------------
#-- VALIDACIÓN Y RESULTADOS
#-----------------------------------------------
func _on_carta_seleccionada(carta: CartaVolteable) -> void:
	if _finalizado: return
	
	# Detenemos el tiempo apenas el niño toma una decisión
	ctrl_tiempo.detener()
	
	var tipo_seleccionado: String = ""
	if carta == mover_raton: tipo_seleccionado = "mover_raton"
	elif carta == escribir: tipo_seleccionado = "escribir"
	elif carta == sonido: tipo_seleccionado = "sonido"
	
	if _imagen_actual["tipo"] == tipo_seleccionado:
		lbl_texto.text = "¡Correcto! Es para " + tipo_seleccionado.replace("_", " ")
		lbl_texto.modulate = Color.CYAN
		finalizar_exito()
	else:
		lbl_texto.text = "Incorrecto. Intenta de nuevo"
		lbl_texto.modulate = Color.ORANGE
		# Podríamos dar otra oportunidad o fallar directo según tu diseño:
		finalizar_fracaso()

func _al_morir_por_tiempo():
	lbl_texto.text = "¡Se acabó el tiempo!"
	finalizar_fracaso()

#------------------------------------------------
#-- BOTONES DE SISTEMA
#-----------------------------------------------
func _on_reiniciar_pressed() -> void:
	_iniciar_secuencia()

func _on_salir_pressed() -> void:
	ctrl_tiempo.detener()
	cancelar_actividad()

func _on_btn_ayuda_pressed() -> void:
	if voz_guia.playing: return
	
	ctrl_tiempo.pausar(true) # Pausamos el tiempo mientras escucha la ayuda
	voz_guia.play()
	
	await voz_guia.finished
	if not _finalizado:
		ctrl_tiempo.pausar(false) # Reanudamos

func configurar_con_parametros(parametros: Dictionary) -> void:
	if parametros.has("tiempo"):
		tiempo_maximo = float(parametros["tiempo"])
		ctrl_tiempo.iniciar(tiempo_maximo)
