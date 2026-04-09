extends ActividadBase
class_name Actividad1

# ===========================
# Referencias UI
# ===========================
@onready var lbl_intentos: Label = $LblIntentos
@onready var salida_texto: Label = $SalidaTexto
@onready var datos_ui: Array = [$HBoxClaves/Dato1, $HBoxClaves/Dato2, $HBoxClaves/Dato3, $HBoxClaves/Dato4]

@onready var btn_arriba: TextureButton = $BtnArriba
@onready var btn_izquierda: TextureButton = $BtnIzquierda
@onready var btn_abajo: TextureButton = $BtnAbajo
@onready var btn_derecha: TextureButton = $BtnDerecha

@onready var btn_confirmar: Button = $BtnConfirmar
@onready var btn_borrar: Button = $BtnBorrar
@onready var btn_ayuda: Button = $BtnAyuda
@onready var btn_salir: Button = $UI/BtnSalir

@onready var audio_ayuda: AudioStreamPlayer = $AudioAyuda
@onready var ctrl_tiempo: ControlTiempo = $UI/ControlTiempo # El nuevo componente

# ===========================
# Variables de Estado
# ===========================
var contrasenna_correcta: Array = []
var contrasenna_ingresada: Array = []
var intentos: int = 3
@export var tiempo_maximo: float = 30.0
var _texto_pendiente: String = "Ingresa la contraseña"

# ===========================
# Ciclo de Vida
# ===========================
func _ready() -> void:
	super._ready()
	
	# Configuración UI inicial
	if lbl_intentos: lbl_intentos.text = "Intentos: %d" % intentos
	salida_texto.text = _texto_pendiente
	actualizar_pantalla()
	
	# VINCULAR COMPONENTE DE TIEMPO
	ctrl_tiempo.vincular_ui(salida_texto, btn_salir, func(h): habilitar_esc = h)
	ctrl_tiempo.tiempo_agotado.connect(_al_morir_por_tiempo)
	ctrl_tiempo.iniciar(tiempo_maximo)
	
	# Conectar Botones
	btn_arriba.pressed.connect(_on_boton_numero_pressed.bind(1))
	btn_izquierda.pressed.connect(_on_boton_numero_pressed.bind(2))
	btn_abajo.pressed.connect(_on_boton_numero_pressed.bind(3))
	btn_derecha.pressed.connect(_on_boton_numero_pressed.bind(4))
	
	btn_borrar.pressed.connect(_on_btn_borrar_pressed)
	btn_confirmar.pressed.connect(_on_btn_confirmar_pressed)
	btn_salir.pressed.connect(_on_salir_pressed)
	if btn_ayuda: btn_ayuda.pressed.connect(_on_btn_ayuda_pressed)

# ===========================
# Lógica de Entrada
# ===========================
func _on_boton_numero_pressed(numero: int) -> void:
	if contrasenna_ingresada.size() < 4:
		contrasenna_ingresada.append(numero)
		actualizar_pantalla()

func _unhandled_input(event: InputEvent) -> void:
	if not btn_confirmar.disabled and intentos > 0: 
		if event.is_action_pressed("ui_up"):
			_on_boton_numero_pressed(1)
			_animar_boton(btn_arriba)
		elif event.is_action_pressed("ui_left"):
			_on_boton_numero_pressed(2)
			_animar_boton(btn_izquierda)
		elif event.is_action_pressed("ui_down"):
			_on_boton_numero_pressed(3)
			_animar_boton(btn_abajo)
		elif event.is_action_pressed("ui_right"):
			_on_boton_numero_pressed(4)
			_animar_boton(btn_derecha)
		elif event.is_action_pressed("ui_accept"):
			_on_btn_confirmar_pressed()

func _animar_boton(boton: TextureButton) -> void:
	boton.modulate = Color(0.7, 0.7, 0.7)
	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(boton):
		boton.modulate = Color(1, 1, 1)

# ===========================
# Lógica de Validación
# ===========================
func _on_btn_confirmar_pressed() -> void:
	if contrasenna_ingresada.size() < 4:
		_mostrar_mensaje_temporal("Contraseña incompleta", 2.0, Color.ORANGE)
		return
	
	if contrasenna_ingresada == contrasenna_correcta:
		ctrl_tiempo.detener()
		salida_texto.text = "¡Contraseña correcta!"
		finalizar_exito()
	else:
		_manejar_error()

func _manejar_error():
	intentos -= 1
	if lbl_intentos: lbl_intentos.text = "Intentos: %d" % intentos
	
	if intentos <= 0:
		ctrl_tiempo.detener()
		salida_texto.text = "¡SIN INTENTOS!"
		btn_confirmar.disabled = true
		await get_tree().create_timer(1.0).timeout
		finalizar_fracaso()
	else:
		_mostrar_mensaje_temporal("Contraseña incorrecta", 2.0, Color.BROWN)
		contrasenna_ingresada.clear()
		actualizar_pantalla()

# ===========================
# Helpers y UI
# ===========================
func actualizar_pantalla() -> void:
	for i in range(datos_ui.size()):
		if i < contrasenna_ingresada.size():
			datos_ui[i].text = _get_flecha_simbolo(contrasenna_ingresada[i])
		else:
			datos_ui[i].text = "*"

func _get_flecha_simbolo(id: int) -> String:
	match id:
		1: return "↑"
		2: return "←"
		3: return "↓"
		4: return "→"
	return "?"

func _on_btn_ayuda_pressed():
	if audio_ayuda:
		audio_ayuda.play()
		_mostrar_mensaje_temporal("¡Escucha las flechas!", 3.0, Color.AQUA)

func _mostrar_mensaje_temporal(nuevo_texto: String, duracion: float = 3.0, color: Color = Color.WHITE) -> void:
	if salida_texto:
		var color_orig = salida_texto.modulate
		salida_texto.text = nuevo_texto
		salida_texto.modulate = color
		await get_tree().create_timer(duracion).timeout
		if not _finalizado and salida_texto:
			salida_texto.text = _texto_pendiente
			salida_texto.modulate = color_orig

# ===========================
# Callbacks de Sistema
# ===========================
func configurar_con_parametros(parametros: Dictionary) -> void:
	if parametros.has("codigo"):
		contrasenna_correcta = []
		for elemento in parametros["codigo"]:
			contrasenna_correcta.append(int(elemento))
	
	if parametros.has("intentos"):
		intentos = int(parametros["intentos"])
		if lbl_intentos: lbl_intentos.text = "Intentos: %d" % intentos
		
	if parametros.has("tiempo"):
		tiempo_maximo = float(parametros["tiempo"])
		ctrl_tiempo.iniciar(tiempo_maximo)

func _al_morir_por_tiempo():
	finalizar_fracaso()

func _on_btn_borrar_pressed() -> void:
	contrasenna_ingresada.clear()
	actualizar_pantalla()

func _on_salir_pressed() -> void:
	cancelar_actividad()
