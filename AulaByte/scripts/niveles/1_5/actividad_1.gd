extends ActividadBase
class_name Actividad1

# ===========================
# Referencias UI
# ===========================
@onready var lbl_intentos: Label = $LblIntentos
@onready var salida_texto: Label = $SalidaTexto
@onready var dato_1: Label = $HBoxClaves/Dato1
@onready var dato_2: Label = $HBoxClaves/Dato2
@onready var dato_3: Label = $HBoxClaves/Dato3
@onready var dato_4: Label = $HBoxClaves/Dato4
@onready var btn_derecha: TextureButton = $BtnDerecha
@onready var btn_izquierda: TextureButton = $BtnIzquierda
@onready var btn_arriba: TextureButton = $BtnArriba
@onready var btn_abajo: TextureButton = $BtnAbajo
@onready var btn_confirmar: Button = $BtnConfirmar
@onready var btn_salir: Button = $BtnSalir
@onready var btn_borrar: Button = $BtnBorrar
@onready var btn_ayuda: Button = $BtnAyuda
@onready var audio_ayuda: AudioStreamPlayer = $AudioAyuda
@onready var timer_limite: Timer = $TimerLimite
@onready var lbl_tiempo: Label = $LblTiempo

# ===========================
# Variables
# ===========================
var contrasenna_correcta: Array[int] = []
var contrasenna_ingresada: Array[int] = []
var intentos: int = 3
@export var tiempo_maximo: float = 30.0
var tiempo_restante: float = 0.0
var actividad_activa: bool = true

func _ready() -> void:
	btn_arriba.pressed.connect(_on_boton_numero_pressed.bind(1))
	btn_izquierda.pressed.connect(_on_boton_numero_pressed.bind(2))
	btn_abajo.pressed.connect(_on_boton_numero_pressed.bind(3))
	btn_derecha.pressed.connect(_on_boton_numero_pressed.bind(4))
	
	btn_borrar.pressed.connect(_on_btn_borrar_pressed)
	btn_confirmar.pressed.connect(_on_btn_confirmar_pressed)
	btn_salir.pressed.connect(_on_btn_salir_pressed)
	
	timer_limite.one_shot = true
	timer_limite.timeout.connect(_on_tiempo_agotado)
	
	reiniciar_tiempo()
	# Texto inicial
	if lbl_intentos:
		lbl_intentos.text = "Intentos: %d" % intentos
	salida_texto.text = "Ingresa la contraseña"
	
	actualizar_pantalla()

func _process(delta: float) -> void:
	if actividad_activa and not timer_limite.is_stopped():
		tiempo_restante = timer_limite.time_left
		lbl_tiempo.text = "Tiempo: %d" % ceil(tiempo_restante)
		
		if tiempo_restante < 5.0:
			lbl_tiempo.modulate = Color.RED

func _on_boton_numero_pressed(numero: int) -> void:
	if contrasenna_ingresada.size() < 4:
		contrasenna_ingresada.append(numero)
		actualizar_pantalla()
		
#-----------------------------------------------------------
#-- CONTROL POR TECLADO
#-----------------------------------------------------------
func _unhandled_input(event: InputEvent) -> void:
	# Verificamos si la actividad ya terminó o está bloqueada
	if not btn_confirmar.disabled and intentos > 0: 
		
		if event.is_action_pressed("ui_up"):
			_on_boton_numero_pressed(1)
			_animar_boton(btn_arriba) # Opcional: Feedback visual
			
		elif event.is_action_pressed("ui_left"):
			_on_boton_numero_pressed(2)
			_animar_boton(btn_izquierda) # Opcional: Feedback visual
			
		elif event.is_action_pressed("ui_down"):
			_on_boton_numero_pressed(3)
			_animar_boton(btn_abajo) # Opcional: Feedback visual
			
		elif event.is_action_pressed("ui_right"):
			_on_boton_numero_pressed(4)
			_animar_boton(btn_derecha) # Opcional: Feedback visual
			
		elif event.is_action_pressed("ui_accept"):
			_on_btn_confirmar_pressed()

# Función opcional para que el botón en pantalla "brille" al pulsar la tecla
func _animar_boton(boton: TextureButton) -> void:

	boton.modulate = Color(0.7, 0.7, 0.7) # Se oscurece un poco
	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(boton):
		boton.modulate = Color(1, 1, 1) # Vuelve a color normal


func _on_btn_confirmar_pressed() -> void:
	if contrasenna_ingresada.size() < 4:
		salida_texto.text = "Contraseña incompleta"
		return
	if contrasenna_ingresada == contrasenna_correcta:
		actividad_activa = false
		timer_limite.stop()
		salida_texto.text = "¡Contraseña correcta!"
		await get_tree().create_timer(1.0).timeout
		finalizar_exito()
		
	var acierto := contrasenna_ingresada == contrasenna_correcta
	
	if acierto:
		salida_texto.text = "¡Contraseña correcta!"
		await get_tree().create_timer(1.0).timeout
		finalizar_exito()
	else:
		intentos -= 1
		
		if intentos <= 0:
			if lbl_intentos:
				lbl_intentos.text = "Sin intentos"
			salida_texto.text = "Contraseña incorrecta."
			
			await get_tree().create_timer(1.5).timeout
			finalizar_fracaso()
		else:
			salida_texto.text = "Contraseña incorrecta"
			if lbl_intentos:
				lbl_intentos.text = "Intentos restantes: %d" % intentos
			contrasenna_ingresada.clear()
			actualizar_pantalla()


func actualizar_pantalla() -> void:
	var datos := [dato_1, dato_2, dato_3, dato_4]
	
	for i in range(datos.size()):
		if i < contrasenna_ingresada.size():
			var valor := contrasenna_ingresada[i]  # 1,2,3,4
			match valor:
				1:
					datos[i].text = "↑"
				2:
					datos[i].text = "←"
				3:
					datos[i].text = "↓"
				4:
					datos[i].text = "→"
		else:
			datos[i].text = "*"


func _on_btn_borrar_pressed() -> void:
	contrasenna_ingresada.clear()
	actualizar_pantalla()
	salida_texto.text = "Ingresa la contraseña"


func _on_btn_salir_pressed() -> void:
	cancelar_actividad()

#-- Recibir parámetros desde GameManager / puerta
func configurar_con_parametros(parametros: Dictionary) -> void:
	if parametros.has("codigo"):
		contrasenna_correcta = []
		for elemento in parametros["codigo"]:
			contrasenna_correcta.append(int(elemento))
		print("Código correcto establecido desde parámetros: ", contrasenna_correcta)
	
	if parametros.has("intentos"):
		intentos = int(parametros["intentos"])
	
	if lbl_intentos:
		lbl_intentos.text = "Intentos: %d" % intentos
		
	if parametros.has("tiempo"):
		tiempo_maximo = float(parametros["tiempo"])
		reiniciar_tiempo()
		
func reiniciar_tiempo() -> void:
	tiempo_restante = tiempo_maximo
	timer_limite.start(tiempo_maximo)
	
func _on_tiempo_agotado() -> void:
	actividad_activa = false
	salida_texto.text = "¡Se acabó el tiempo!"
	btn_confirmar.disabled = true
	
	await get_tree().create_timer(1.5).timeout
	finalizar_fracaso()

func _on_button_pressed() -> void:
	audio_ayuda.play()
