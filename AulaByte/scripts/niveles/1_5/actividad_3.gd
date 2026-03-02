extends ActividadBase
class_name Actividad3

@onready var lbl_ganar: Label = $UI/LblGanar
@onready var lbl_intentos: Label = $UI/LblIntentos
@onready var teclado_zona: TecladoZona = $TecladoZona
@onready var contenedor_objetos: Control = $ContenedorObjetos
@onready var btn_salir: Button = $UI/BtnSalir
@onready var btn_ayuda: Button = $UI/BtnAyuda
@onready var audio_ayuda: AudioStreamPlayer = $AudioAyuda

@export var intentos: int = 5
@export var tiempo_mensaje: float = 2.0

var _total_objetos := 0
var _aciertos := 0
var _cerrado := false
const MSJ_ORIGINAL := "¡Cada cosa en su lugar!"

func _ready() -> void:
	super._ready()
	
	btn_salir.pressed.connect(_on_btn_salir_pressed)
	
	# Mensaje inicial
	lbl_ganar.text = MSJ_ORIGINAL
	lbl_ganar.modulate = Color.WHITE
	lbl_ganar.scale = Vector2(1.0, 1.0)
	lbl_ganar.visible = true
	
	_contar_objetos()
	_actualizar_intentos()
	teclado_zona.soltar_item.connect(_on_item_dropped)

func _contar_objetos() -> void:
	_total_objetos = 0
	for c in contenedor_objetos.get_children():
		if c is TeclaArrastrable:
			_total_objetos += 1

func _actualizar_intentos() -> void:
	if lbl_intentos:
		lbl_intentos.text = "Intentos: %d" % intentos
		lbl_intentos.modulate = Color.WHITE # Resetear color

func _on_item_dropped(correcto: bool) -> void:
	if _cerrado: return
	
	if correcto:
		_aciertos += 1
		# Elegimos una frase motivadora al azar
		var frases_bien = ["¡Correcto!", "¡Eres muy bueno!", "Eres un genio"]
		_mostrar_feedback_temporal(frases_bien.pick_random(), Color.GREEN)
		
		if _aciertos >= _total_objetos:
			_cerrado = true
			_ganar()
	else:
		intentos -= 1
		_actualizar_intentos()
		
		if intentos <= 0:
			_cerrado = true
			_perder()
		else:
			# Elegimos una frase de apoyo al azar
			var frases_mal = ["¡Inténtalo nuevamente!", "¡Vamos, tú puedes!", "De los errores aprendemos"]
			_mostrar_feedback_temporal(frases_mal.pick_random(), Color.RED)

# Función de feedback temporal (con reset de escala)
func _mostrar_feedback_temporal(texto: String, color: Color) -> void:
	lbl_ganar.text = texto
	lbl_ganar.modulate = color
	lbl_ganar.scale = Vector2(1.0, 1.0)
	
	await get_tree().create_timer(tiempo_mensaje).timeout
	
	if not _cerrado:
		lbl_ganar.text = MSJ_ORIGINAL
		lbl_ganar.modulate = Color.WHITE
		lbl_ganar.scale = Vector2(1.0, 1.0)

func _ganar() -> void:
	lbl_ganar.text = "¡Excelente! Teclado completado"
	lbl_ganar.modulate = Color.CYAN
	await get_tree().create_timer(0.4).timeout
	finalizar_exito()

func _perder() -> void:
	if lbl_intentos:
		lbl_intentos.text = "¡Sin intentos!"
		lbl_intentos.modulate = Color.RED
	
	lbl_ganar.text = "Sé que podrás la próxima"
	lbl_ganar.modulate = Color.ORANGE
	# Reducimos escala para que quepa perfecto
	lbl_ganar.scale = Vector2(0.85, 0.85) 
	
	await get_tree().create_timer(0.4).timeout
	finalizar_fracaso()

func configurar_con_parametros(parametros: Dictionary) -> void:
	if parametros.has("intentos"):
		intentos = max(1, int(parametros["intentos"]))
		_actualizar_intentos()
		
func _on_btn_salir_pressed() -> void:
	cancelar_actividad()

func _on_btn_ayuda_pressed() -> void:
	audio_ayuda.play()
