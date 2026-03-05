extends ActividadBase
class_name Actividad4

enum Fase {INTRO1, INTRO2, ELECCION, RESULTADO}

@export_group("Audios Guía")
@export var audio_intro_1: AudioStream
@export var audio_intro_2: AudioStream
@export var audio_eleccion: AudioStream

@export_group("Configuración")
@export var tiempo_espera_post_audio: float = 1.5 

@onready var zona_cartas: Control = $Fondo/ZonaCartas
@onready var btn_aceptar: Button = $UI/BtnAceptar
@onready var carta_bici: TextureRect = $Fondo/CartaBici
@onready var carta_bus: TextureRect = $Fondo/CartaBus
@onready var carta_camion: TextureRect = $Fondo/CartaCamion
@onready var btn_reiniciar: Button = $UI/BtnReiniciar
@onready var carta_carro: TextureRect = $Fondo/CartaCarro
@onready var lbl_texto: Label = $UI/LblTexto
@onready var btn_salir: Button = $UI/BtnSalir
@onready var lbl_guia: Label = $UI/LblGuia
@onready var btn_ayuda: Button = $UI/BtnAyuda

@onready var audio_guia: AudioStreamPlayer = $AudioGuia
@onready var voz_ayuda: AudioStreamPlayer = $VozAyuda
@onready var ctrl_tiempo: ControlTiempo = $UI/ControlTiempo 

var _seleccion: CartaVolteable = null
var _cartas: Array[CartaVolteable] = []
var _fase: int = Fase.INTRO1
var _contador: int = 0
var _interaccion_habilitada := false

@export var tiempo_maximo: float = 20.0

func _ready() -> void:
	super._ready()
	
	# 1. VINCULACIÓN DEL COMPONENTE
	ctrl_tiempo.vincular_ui(lbl_texto, btn_salir, func(h): habilitar_esc = h)
	ctrl_tiempo.tiempo_agotado.connect(_on_tiempo_agotado)
	
	# 2. CONEXIÓN DE BOTONES
	btn_aceptar.pressed.connect(_on_btn_aceptar_pressed)
	btn_reiniciar.pressed.connect(_on_btn_reiniciar_pressed)
	btn_salir.pressed.connect(_on_salir_pressed) # Corregido el nombre aquí
	if btn_ayuda: 
		btn_ayuda.pressed.connect(_on_btn_ayuda_pressed)
	
	_reunir_cartas()
	_iniciar_secuencia()

# --- FUNCIONES DE APOYO VISUAL (Corrigiendo errores de "Function not found") ---

func _limpiar_escena_visual() -> void:
	zona_cartas.visible = false
	carta_carro.visible = false
	carta_bici.visible = false
	carta_bus.visible = false
	carta_camion.visible = false

func _cambiar_fase_visual(mostrar_carro: bool) -> void:
	carta_bici.visible = not mostrar_carro
	carta_bus.visible = not mostrar_carro
	carta_camion.visible = not mostrar_carro
	carta_carro.visible = mostrar_carro

# --------------------------------------------------------------------------------

func _reunir_cartas() -> void:
	_cartas.clear()
	for n in zona_cartas.get_children():
		if n is CartaVolteable:
			var c := n as CartaVolteable
			_cartas.append(c)
			if not c.carta_volteada.is_connected(_on_carta_volteada):
				c.carta_volteada.connect(_on_carta_volteada)
			if not c.carta_seleccionada.is_connected(_on_carta_seleccionada):
				c.carta_seleccionada.connect(_on_carta_seleccionada)

func _iniciar_secuencia() -> void:
	ctrl_tiempo.detener() 
	audio_guia.stop() 
	_contador += 1
	var id_actual := _contador
	
	lbl_guia.visible = false
	_interaccion_habilitada = false
	btn_aceptar.disabled = true
	_seleccion = null
	
	for c in _cartas: c.deseleccionar_y_cerrar()
		
	_limpiar_escena_visual()
	
	# --- FASE 1: PREMISA MAYOR ---
	_fase = Fase.INTRO1
	carta_bici.visible = true
	carta_bus.visible = true
	carta_camion.visible = true
	await _narrar_fase("Todos los vehículos tienen ruedas.", audio_intro_1)
	if id_actual != _contador: return
	
	# --- FASE 2: PREMISA MENOR ---
	_fase = Fase.INTRO2
	_cambiar_fase_visual(true) 
	await _narrar_fase("El carro es un vehículo.", audio_intro_2)
	if id_actual != _contador: return
	
	# --- FASE 3: CONCLUSIÓN ---
	_fase = Fase.ELECCION
	carta_carro.visible = false
	zona_cartas.visible = true
	
	await _narrar_fase("Elige la carta que completa el silogismo.", audio_eleccion, true)
	
	if id_actual == _contador and _fase == Fase.ELECCION:
		_interaccion_habilitada = true
		ctrl_tiempo.iniciar(tiempo_maximo) 
		_esperar_instruccion_doble_clic(id_actual)

func _on_tiempo_agotado() -> void:
	if not _finalizado:
		_interaccion_habilitada = false
		lbl_texto.text = "¡Se acabó el tiempo!"
		finalizar_fracaso()

func _narrar_fase(texto: String, audio: AudioStream, esperar_terminar: bool = true) -> void:
	lbl_texto.text = texto
	if audio:
		audio_guia.stream = audio
		audio_guia.play()
		if esperar_terminar:
			await audio_guia.finished
			await get_tree().create_timer(tiempo_espera_post_audio).timeout
	elif esperar_terminar:
		await get_tree().create_timer(3.0).timeout

func _esperar_instruccion_doble_clic(id_en_curso: int) -> void:
	if audio_guia.playing:
		await audio_guia.finished
	await get_tree().create_timer(0.5).timeout
	if id_en_curso == _contador and _fase == Fase.ELECCION and not _finalizado:
		lbl_guia.text = "(Doble clic para elegir)"
		lbl_guia.visible = true

func _on_carta_volteada(carta: CartaVolteable) -> void:
	if not _interaccion_habilitada: return
	for c in _cartas:
		if c != carta: c.forzar_cierre()

func _on_carta_seleccionada(carta: CartaVolteable) -> void:
	if not _interaccion_habilitada: return
	for c in _cartas:
		if c != carta: c.deseleccionar_y_cerrar()
	_seleccion = carta
	btn_aceptar.disabled = false

func _on_btn_aceptar_pressed() -> void:
	if _seleccion == null: return
	ctrl_tiempo.detener()
	_interaccion_habilitada = false
	audio_guia.stop() 
	if _seleccion.es_correcta:
		finalizar_exito()
	else:
		finalizar_fracaso()

func configurar_con_parametros(parametros: Dictionary) -> void:
	if parametros.has("tiempo"):
		tiempo_maximo = float(parametros["tiempo"])

func _on_btn_reiniciar_pressed() -> void:
	_iniciar_secuencia()
	
func _on_salir_pressed() -> void:
	audio_guia.stop()
	cancelar_actividad()

func _on_btn_ayuda_pressed() -> void:
	if voz_ayuda.playing: return
	var id_al_presionar = _contador
	ctrl_tiempo.pausar(true) 
	btn_ayuda.disabled = true 
	voz_ayuda.play()
	await voz_ayuda.finished
	if id_al_presionar == _contador and not _finalizado and _fase == Fase.ELECCION:
		ctrl_tiempo.pausar(false) 
		btn_ayuda.disabled = false
