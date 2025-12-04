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
var _total_objetos := 0
var _aciertos := 0
var _cerrado := false

func _ready() -> void:
	super._ready()
	
	btn_salir.pressed.connect(_on_btn_salir_pressed)
	
	lbl_ganar.visible = false
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

func _on_item_dropped(correcto: bool) -> void:
	if _cerrado: return
	if correcto:
		_aciertos += 1
		lbl_ganar.text = "¡Correcto!"
		lbl_ganar.visible = true
		if _aciertos >= _total_objetos:
			_cerrado = true
			await get_tree().create_timer(0.4).timeout
			finalizar_exito()
	else:
		intentos -= 1
		_actualizar_intentos()
		lbl_ganar.text = "Ups, intenta de nuevo"
		lbl_ganar.visible = true
		if intentos <= 0:
			_cerrado = true
			await get_tree().create_timer(0.4).timeout
			finalizar_fracaso()

# nombre que espera tu base
func configurar_con_parametros(parametros: Dictionary) -> void:
	if parametros.has("intentos"):
		intentos = max(1, int(parametros["intentos"]))
		_actualizar_intentos()
		
func _on_btn_salir_pressed() -> void:
	cancelar_actividad()


func _on_btn_ayuda_pressed() -> void:
	audio_ayuda.play()
