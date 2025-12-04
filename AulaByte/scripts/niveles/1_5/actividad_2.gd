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

@export var intentos: int = 5

var _total_objetos: int = 0
var _objeto_correcto: int = 0

func _ready() -> void:
	super._ready()
	
	btn_salir.pressed.connect(_on_btn_salir_pressed)
	
	lbl_ganar.visible = false
	_conectar_carpetas()
	_contar_objetos()
	_actualizar_intentos()


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
		lbl_ganar.text = "¡Bien hecho!"
		lbl_ganar.visible = true
		if _objeto_correcto >= _total_objetos:
			_ganar()
	else:
		intentos -= 1
		lbl_ganar.text = "UPS"
		lbl_ganar.visible = true
		_actualizar_intentos()
		if intentos <= 0:
			_perder()


func _ganar() -> void:
	if _finalizado:
		return

	lbl_ganar.text = "¡Bien hecho!"
	lbl_ganar.visible = true

	actividad_superada.emit()
	_bloquear_objetos_arrastrables()

	# Usa la API común de ActividadBase (emite resuelto(true))
	finalizar_exito()


func _perder() -> void:
	if _finalizado:
		return

	lbl_ganar.text = "Sin intentos."
	lbl_ganar.visible = true

	actividad_fallida.emit()
	_bloquear_objetos_arrastrables()

	# Usa la API común de ActividadBase (emite resuelto(false))
	finalizar_fracaso()


func _bloquear_objetos_arrastrables() -> void:
	for c in contenedor_objetos.get_children():
		if c is ObjetoArrastrable and is_instance_valid(c):
			c.mouse_filter = Control.MOUSE_FILTER_IGNORE


# Permite que el GameManager / nivel configure intentos vía parámetros
func configurar_con_parametros(parametros: Dictionary) -> void:
	if parametros.has("intentos"):
		intentos = max(1, int(parametros["intentos"]))
		
func _on_btn_salir_pressed() -> void:
	cancelar_actividad()


func _on_btn_ayuda_pressed() -> void:
	audio_ayuda.play()
