extends ActividadBase
class_name Actividad5

enum Fase { ELECCION, RESULTADO }

@export var t_intro1 := 5.0
@export var t_intro2 := 5.0

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

var _cartas: Array = []
var _seleccion: Node = null
var _imagen_actual: Dictionary

const IMAGENES := [
	{ "ruta": "res://recursos/imagenes/niveles/nivel5/actividad5/raton.png", "tipo": "mover_raton" },
	{ "ruta": "res://recursos/imagenes/niveles/nivel5/actividad5/teclado.png", "tipo": "escribir" },
	{ "ruta": "res://recursos/imagenes/niveles/nivel5/actividad5/microfono.png", "tipo": "sonido" }
]

#-----------------------------------------------------------
#-- CICLO DE VIDA
#-----------------------------------------------------------
func _ready() -> void:
	super._ready()
	lbl_texto.text = "Selecciona la carta correcta según la imagen."
	_reunir_cartas()

	if not btn_aceptar.pressed.is_connected(_on_btn_aceptar_pressed):
		btn_aceptar.pressed.connect(_on_btn_aceptar_pressed)
	if not btn_reiniciar.pressed.is_connected(_on_btn_reiniciar_pressed):
		btn_reiniciar.pressed.connect(_on_btn_reiniciar_pressed)
	btn_salir.pressed.connect(_on_btn_salir_pressed)

	_iniciar_secuencia()

#-----------------------------------------------------------
#-- FUNCIONES DE APOYO
#-----------------------------------------------------------
func _cargar_imagen_aleatoria() -> void:
	_imagen_actual = IMAGENES[randi() % IMAGENES.size()]
	var ruta: String = _imagen_actual["ruta"]
	var textura := load(ruta)
	if textura: 
		var tam_padre: Vector2 = contenedor_imagen.size 
		var tam_objetivo: Vector2 = tam_padre * 0.8 
		
		imagen_aleatoria.texture = textura 
		
		imagen_aleatoria.anchor_left = 0.5 
		imagen_aleatoria.anchor_top = 0.5 
		imagen_aleatoria.anchor_right = 0.5 
		imagen_aleatoria.anchor_bottom = 0.5 
		
		imagen_aleatoria.size = tam_objetivo 
		imagen_aleatoria.custom_minimum_size = tam_objetivo 
		imagen_aleatoria.pivot_offset = imagen_aleatoria.size / 2 
		imagen_aleatoria.position = Vector2.ZERO + 0.05*tam_objetivo 
		imagen_aleatoria.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED 
	else: 
		push_warning("No se pudo cargar la textura: " + ruta)

func _reunir_cartas() -> void:
	_cartas.clear()
	for n in zona_cartas.get_children():
		n.forzar_cierre()
		_cartas.append(n)

#-----------------------------------------------------------
#-- SECUENCIA SIMPLIFICADA
#-----------------------------------------------------------
func _iniciar_secuencia() -> void:
	_seleccion = null
	btn_aceptar.disabled = true
	_cargar_imagen_aleatoria()
	_reunir_cartas()

#------------------------------------------------
#-- BOTONES
#-----------------------------------------------
func _on_btn_aceptar_pressed() -> void:
	print("Botón Aceptar presionado")

func _on_btn_reiniciar_pressed() -> void:
	_iniciar_secuencia()

#------------------------------------------------
#-- VALIDACIÓN DE CARTAS
#-----------------------------------------------
func _on_mover_raton_carta_seleccionada(carta: CartaVolteable) -> void:
	if _imagen_actual and _imagen_actual["tipo"] == "mover_raton":
		finalizar_exito()
	else:
		finalizar_fracaso()

func _on_escribir_carta_seleccionada(carta: CartaVolteable) -> void:
	if _imagen_actual and _imagen_actual["tipo"] == "escribir":
		finalizar_exito()
	else:
		finalizar_fracaso()

func _on_sonido_carta_seleccionada(carta: CartaVolteable) -> void:
	if _imagen_actual and _imagen_actual["tipo"] == "sonido":
		finalizar_exito()
	else:
		finalizar_fracaso()
		
func _on_btn_salir_pressed() -> void:
	cancelar_actividad()
