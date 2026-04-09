extends ActividadBase
class_name Actividad10

# --- Referencias ---
@onready var contenedor_botones: GridContainer = $ContenedorBotones
@onready var entrada_container: HBoxContainer = $Slots
@onready var btn_confirmar: Button = $UI/BtnConfirmar
@onready var btn_borrar: Button = $UI/BtnBorrar
@onready var etiqueta_mensaje: Label = $EtiquetaMensaje
@onready var etiqueta_intentos: Label = $EtiquetaIntentos 
@onready var btn_salir: Button = $UI/BtnSalir
@onready var btn_ayuda: Button = $BtnAyuda
@onready var aud_ayuda: AudioStreamPlayer = $AudAyuda
@onready var ctrl_tiempo: ControlTiempo = $UI/ControlTiempo

# --- Configuración ---
const COLORES_ID = {
	1: "azul", 2: "amarilla", 3: "roja",
	4: "morada", 5: "verde", 6: "rosa", 7: "naranja"
}

@export var tiempo_total: float = 30.0
var intentos: int = 3

# --- Estado ---
var secuencia_correcta: Array = []
var entrada_actual: Array = []
var _texto_pendiente: String = "Ingresa la secuencia"

# --------------------------------------------------
# CICLO DE VIDA
# --------------------------------------------------

func _ready():
	super._ready()

	# UI inicial
	if etiqueta_mensaje:
		etiqueta_mensaje.text = _texto_pendiente

	if etiqueta_intentos:
		etiqueta_intentos.text = "Intentos: %d" % intentos

	# Vincular componente de tiempo
	ctrl_tiempo.vincular_ui(
		etiqueta_mensaje,
		btn_salir,
		func(h): habilitar_esc = h
	)

	ctrl_tiempo.tiempo_agotado.connect(_al_morir_por_tiempo)

	# Iniciar temporizador
	ctrl_tiempo.iniciar(tiempo_total)

	# Construir botones
	_preparar_interfaz_colores()

	# Conectar señales
	btn_confirmar.pressed.connect(_on_confirmar_pressed)
	btn_borrar.pressed.connect(_on_borrar_pressed)
	btn_salir.pressed.connect(_on_salir_pressed)

	if btn_ayuda:
		btn_ayuda.pressed.connect(_on_btn_ayuda_pressed)


func configurar_con_parametros(parametros: Dictionary) -> void:

	if parametros.has("codigo"):
		secuencia_correcta = parametros.codigo
		_texto_pendiente = "Ingresa la secuencia de %d colores" % secuencia_correcta.size()

		if etiqueta_mensaje:
			etiqueta_mensaje.text = _texto_pendiente

	if parametros.has("intentos"):
		intentos = parametros.intentos

		if etiqueta_intentos:
			etiqueta_intentos.text = "Intentos: %d" % intentos

	# Permitir que el nivel cambie el tiempo
	if parametros.has("tiempo"):
		tiempo_total = parametros.tiempo
		ctrl_tiempo.iniciar(tiempo_total)


# --------------------------------------------------
# LÓGICA DEL JUEGO
# --------------------------------------------------

func _on_color_pressed(id: int):

	var limite = secuencia_correcta.size() if not secuencia_correcta.is_empty() else 10

	if entrada_actual.size() < limite:
		entrada_actual.append(id)
		actualizar_visual_entrada()


func _on_confirmar_pressed():

	if secuencia_correcta.is_empty():
		_mostrar_mensaje_temporal("Error de secuencia", 2.0, Color.RED)
		return

	if entrada_actual == secuencia_correcta:

		ctrl_tiempo.detener()

		if etiqueta_mensaje:
			etiqueta_mensaje.text = "¡CÓDIGO CORRECTO!"

		finalizar_exito()

	else:
		_manejar_error()


func _manejar_error():

	intentos -= 1

	if etiqueta_intentos:
		etiqueta_intentos.text = "Intentos: %d" % intentos

	if intentos <= 0:

		ctrl_tiempo.detener()

		if etiqueta_mensaje:
			etiqueta_mensaje.text = "¡SIN INTENTOS!"

		btn_confirmar.disabled = true

		await get_tree().create_timer(1.0).timeout

		finalizar_fracaso()

	else:

		_mostrar_mensaje_temporal("¡INCORRECTO!", 2.0, Color.BROWN)

		_on_borrar_pressed()


# --------------------------------------------------
# INTERFAZ
# --------------------------------------------------

func _preparar_interfaz_colores():

	for child in contenedor_botones.get_children():
		child.free()

	for id in COLORES_ID.keys():

		var btn := Button.new()
		btn.custom_minimum_size = Vector2(70,70)

		_aplicar_estilo_boton_color(btn, id)

		btn.pressed.connect(_on_color_pressed.bind(id))

		contenedor_botones.add_child(btn)


func actualizar_visual_entrada():

	for child in entrada_container.get_children():
		child.free()

	for id in entrada_actual:

		var rect := ColorRect.new()
		rect.custom_minimum_size = Vector2(60,60)
		rect.color = _color_from_id(id)

		var borde := ReferenceRect.new()
		borde.border_color = Color.WHITE
		borde.border_width = 2
		borde.editor_only = false
		borde.set_anchors_preset(Control.PRESET_FULL_RECT)

		rect.add_child(borde)

		entrada_container.add_child(rect)


func _color_from_id(id:int) -> Color:

	match id:
		1: return Color(0,0.6,1)
		2: return Color(1,0.8,0)
		3: return Color(0.8,0.1,0.1)
		4: return Color(0.5,0,0.8)
		5: return Color(0.2,0.8,0.2)
		6: return Color(1,0.3,0.6)
		7: return Color(1,0.5,0)

	return Color.WHITE


func _aplicar_estilo_boton_color(btn:Button, id:int):

	var color_base := _color_from_id(id)

	var estilo := StyleBoxFlat.new()
	estilo.bg_color = color_base
	estilo.set_corner_radius_all(8)
	estilo.border_width_bottom = 4
	estilo.border_color = Color(0,0,0,0.2)

	btn.add_theme_stylebox_override("normal", estilo)

	var estilo_h := estilo.duplicate()
	estilo_h.bg_color = color_base.lightened(0.2)

	btn.add_theme_stylebox_override("hover", estilo_h)

# --------------------------------------------------
# SEÑALES
# --------------------------------------------------

func _on_btn_ayuda_pressed():

	if aud_ayuda:
		aud_ayuda.play()

	_mostrar_mensaje_temporal(
		"¡Escucha la pista con atención!",
		3.0,
		Color.AQUA
	)

func _on_borrar_pressed():

	entrada_actual.clear()
	actualizar_visual_entrada()

func _on_salir_pressed():

	ctrl_tiempo.detener()
	cancelar_actividad()

func _al_morir_por_tiempo():

	if etiqueta_mensaje:
		etiqueta_mensaje.text = "¡TIEMPO AGOTADO!"

	finalizar_fracaso()

# --------------------------------------------------
# MENSAJES
# --------------------------------------------------

func _mostrar_mensaje_temporal(
	nuevo_texto:String,
	duracion:float = 3.0,
	color:Color = Color.WHITE
):

	if not etiqueta_mensaje:
		return

	var color_original := etiqueta_mensaje.modulate

	etiqueta_mensaje.text = nuevo_texto
	etiqueta_mensaje.modulate = color

	await get_tree().create_timer(duracion).timeout

	if not _finalizado:
		etiqueta_mensaje.text = _texto_pendiente
		etiqueta_mensaje.modulate = color_original
