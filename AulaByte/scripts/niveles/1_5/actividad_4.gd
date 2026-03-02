extends ActividadBase
class_name Actividad4

enum Fase {INTRO1, INTRO2, ELECCION, RESULTADO}

@export_group("Audios Guía")
@export var audio_intro_1: AudioStream
@export var audio_intro_2: AudioStream
@export var audio_eleccion: AudioStream

@export_group("Configuración")
@export var tiempo_espera_post_audio: float = 1.5 # Tiempo extra después de hablar

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

# Referencia al nuevo nodo de audio
@onready var audio_guia: AudioStreamPlayer = $AudioGuia
@onready var voz_ayuda: AudioStreamPlayer = $VozAyuda

var _seleccion: CartaVolteable = null
var _cartas: Array[CartaVolteable] = []
var _fase: int = Fase.INTRO1
var _contador: int = 0
var _interaccion_habilitada := false

func _ready() -> void:
	super._ready()
	_reunir_cartas()

	if not btn_aceptar.pressed.is_connected(_on_btn_aceptar_pressed):
		btn_aceptar.pressed.connect(_on_btn_aceptar_pressed)
	if not btn_reiniciar.pressed.is_connected(_on_btn_reiniciar_pressed):
		btn_reiniciar.pressed.connect(_on_btn_reiniciar_pressed)
	btn_salir.pressed.connect(_on_btn_salir_pressed)
		
	_iniciar_secuencia()

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

#-----------------------------------------------------------
#-- SECUENCIA PARA EL SILOGISMO (MODIFICADA)
#------------------------------------------------------------
func _iniciar_secuencia() -> void:
	audio_guia.stop() 
	
	_contador += 1
	var id_actual := _contador
	
	lbl_guia.visible = false
	
	_interaccion_habilitada = false
	btn_aceptar.disabled = true
	_seleccion = null
	for c in _cartas:
		c.deseleccionar_y_cerrar()
		
	#-- Estado visual inicial
	zona_cartas.visible = false
	carta_carro.visible = false
	carta_bici.visible = false
	carta_bus.visible = false
	carta_camion.visible = false
	
	# --- FASE 1: PREMISA MAYOR ---
	_fase = Fase.INTRO1
	carta_bici.visible = true
	carta_bus.visible = true
	carta_camion.visible = true
	
	await _narrar_fase("Todos los vehículos tienen ruedas.", audio_intro_1)
	
	# Chequeo de seguridad: Si el usuario reinició mientras hablaba, paramos aquí
	if id_actual != _contador: return
	
	# --- FASE 2: PREMISA MENOR ---
	_fase = Fase.INTRO2
	carta_carro.visible = true
	carta_bici.visible = false
	carta_bus.visible = false
	carta_camion.visible = false
	
	await _narrar_fase("El carro es un vehículo.", audio_intro_2)
	
	if id_actual != _contador: return
	
	# --- FASE 3: CONCLUSIÓN / ELECCIÓN ---
	_fase = Fase.ELECCION
	carta_carro.visible = false
	zona_cartas.visible = true
	_narrar_fase("Elige la carta que completa el silogismo.", audio_eleccion, false)
	_interaccion_habilitada = true
	_esperar_instruccion_doble_clic(id_actual)


# FUNCION AUXILIAR PARA MANEJAR LA NARRACION
# Si 'esperar_terminar' es true, el código se pausa hasta que acabe el audio + delay
func _narrar_fase(texto: String, audio: AudioStream, esperar_terminar: bool = true) -> void:
	lbl_texto.text = texto
	
	if audio:
		audio_guia.stream = audio
		audio_guia.play()
		
		if esperar_terminar:
			# Espera a que termine el audio
			await audio_guia.finished
			# Espera el tiempo extra para que el niño procese la info
			await get_tree().create_timer(tiempo_espera_post_audio).timeout
	else:
		# Si no hay audio asignado (fallback), esperamos un tiempo fijo por defecto
		if esperar_terminar:
			await get_tree().create_timer(3.0).timeout

func _esperar_instruccion_doble_clic(id_en_curso: int) -> void:
	# Si hay un audio sonando, esperamos a que termine
	if audio_guia.playing:
		await audio_guia.finished
	
	await get_tree().create_timer(0.5).timeout
	
	if id_en_curso == _contador and _fase == Fase.ELECCION and not _finalizado:
		lbl_guia.text = "(Doble clic para elegir)"
		lbl_guia.visible = true
		lbl_guia.modulate = Color(0.8, 0.9, 1.0)
		lbl_guia.scale = Vector2(0.9, 0.9) 

#--------------------------------------------------------
#-- INTERACCION CON CARTAS (IGUAL)
#-------------------------------------------------------    
func _on_carta_volteada(carta: CartaVolteable) -> void:
	if not _interaccion_habilitada: return
	for c in _cartas:
		if c != carta:
			c.forzar_cierre()

func _on_carta_seleccionada(carta: CartaVolteable) -> void:
	if not _interaccion_habilitada: return
	for c in _cartas:
		if c != carta:
			c.deseleccionar_y_cerrar()
	_seleccion = carta
	btn_aceptar.disabled = false
	

#------------------------------------------------
#-- BOTONES
#-----------------------------------------------
func _on_btn_aceptar_pressed() -> void:
	if _seleccion == null: return
	_interaccion_habilitada = false
	audio_guia.stop() # Detener instrucción si ya ganó
	if _seleccion.es_correcta:
		finalizar_exito()
	else:
		finalizar_fracaso()
		

func _on_btn_reiniciar_pressed() -> void:
	_iniciar_secuencia()
	
func _on_btn_salir_pressed() -> void:
	# Aseguramos que el audio se calle al salir
	audio_guia.stop()
	cancelar_actividad()

func _on_btn_ayuda_pressed() -> void:
	voz_ayuda.play()
