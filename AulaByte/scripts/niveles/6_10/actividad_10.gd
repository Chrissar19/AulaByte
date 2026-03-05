extends ActividadBase
class_name Actividad10

@onready var contenedor_botones: GridContainer = $ContenedorBotones
@onready var entrada_container: HBoxContainer = $Slots
@onready var btn_confirmar: Button = $UI/BtnConfirmar
@onready var btn_borrar: Button = $UI/BtnBorrar    # Ahora funcionará como BORRAR TODO
@onready var etiqueta_mensaje: Label = $EtiquetaMensaje
@onready var etiqueta_intentos: Label = $EtiquetaIntentos 
@onready var btn_salir: Button = $UI/BtnSalir
@onready var barra_tiempo: ProgressBar = $UI/BarraTiempo
@onready var btn_ayuda: Button = $BtnAyuda
@onready var aud_ayuda: AudioStreamPlayer = $AudAyuda

var secuencia_correcta: Array = [] 
var entrada_actual: Array = []   
var _texto_pendiente: String = "Ingresa la secuencia"
@export var tiempo_total: float = 30.0
var tiempo_restante: float = 15.0
var tiempo_activo: bool = true
var intentos: int = 3

const COLORES_ID = {
	1: "azul", 2: "amarilla", 3: "roja", 
	4: "morada", 5: "verde", 6: "rosa", 7: "naranja"
}

func _ready():
	super._ready()
	
	if etiqueta_mensaje: etiqueta_mensaje.text = _texto_pendiente
	if etiqueta_intentos: etiqueta_intentos.text = "Intentos: %d" % intentos
	
	_preparar_barra_estilo()

	for child in contenedor_botones.get_children(): child.free()
	for id in COLORES_ID.keys():
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(70, 70)
		_aplicar_estilo_boton_color(btn, id)
		btn.pressed.connect(_on_color_pressed.bind(id))
		contenedor_botones.add_child(btn)
	
	# Conexión de botones de control
	btn_confirmar.pressed.connect(_on_confirmar_pressed)
	btn_borrar.pressed.connect(_on_borrar_pressed)
	btn_salir.pressed.connect(_on_salir_pressed)
	
	# --- CONEXIÓN BOTÓN AYUDA ---
	if btn_ayuda:
		btn_ayuda.pressed.connect(_on_btn_ayuda_pressed)
	
	if barra_tiempo:
		barra_tiempo.max_value = tiempo_total
		barra_tiempo.value = tiempo_total
	
	tiempo_restante = tiempo_total
	set_process(true)
	
func _process(delta: float) -> void:
	if not tiempo_activo:
		return
	tiempo_restante -= delta
	if barra_tiempo:
		barra_tiempo.value = tiempo_restante
		
		var porcentaje = tiempo_restante / tiempo_total
		# Usamos colores más vibrantes para que no se "apaguen"
		if porcentaje > 0.5:
			barra_tiempo.modulate = Color.GREEN
		elif porcentaje > 0.25:
			barra_tiempo.modulate = Color.YELLOW # El amarillo destaca mejor que el naranja puro
		else:
			# Efecto de parpadeo suave cuando queda poco tiempo (< 25%)
			var parpadeo = abs(sin(Time.get_ticks_msec() * 0.01))
			barra_tiempo.modulate = Color.RED.lerp(Color(1, 0.5, 0.5), parpadeo)
			_gestionar_bloqueo_salida(true)
			
	if tiempo_restante <= 0:
		tiempo_activo = false
		if etiqueta_mensaje:
			etiqueta_mensaje.text = "¡TIEMPO AGOTADO!"
		finalizar_fracaso()

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

func _on_color_pressed(id: int):
	var limite = secuencia_correcta.size() if secuencia_correcta.size() > 0 else 10
	if entrada_actual.size() < limite:
		entrada_actual.append(id)
		actualizar_visual_entrada()

func actualizar_visual_entrada():
	if not entrada_container: return
	for child in entrada_container.get_children(): child.free()
	for id in entrada_actual:
		var rect = ColorRect.new()
		rect.custom_minimum_size = Vector2(60, 60)
		rect.color = _color_from_id(id)
		
		var borde = ReferenceRect.new()
		borde.border_color = Color.WHITE
		borde.border_width = 2
		borde.editor_only = false
		borde.set_anchors_preset(Control.PRESET_FULL_RECT)
		rect.add_child(borde)
		entrada_container.add_child(rect)

func _color_from_id(id: int) -> Color:
	match id:
		1: return Color(0, 0.6, 1)
		2: return Color(1, 0.8, 0)
		3: return Color(0.8, 0.1, 0.1)
		4: return Color(0.5, 0, 0.8)
		5: return Color(0.2, 0.8, 0.2)
		6: return Color(1, 0.3, 0.6)
		7: return Color(1, 0.5, 0)
	return Color.WHITE

func _aplicar_estilo_boton_color(btn: Button, id: int):
	var color_base = _color_from_id(id)
	var estilo_normal = StyleBoxFlat.new()
	estilo_normal.bg_color = color_base
	estilo_normal.set_corner_radius_all(8)
	estilo_normal.border_width_bottom = 4
	estilo_normal.border_color = Color(0, 0, 0, 0.2)
	
	var estilo_hover = estilo_normal.duplicate()
	estilo_hover.bg_color = color_base.lightened(0.2)
	
	btn.add_theme_stylebox_override("normal", estilo_normal)
	btn.add_theme_stylebox_override("hover", estilo_hover)

func _on_confirmar_pressed():
	if secuencia_correcta.size() == 0:
		if etiqueta_mensaje: etiqueta_mensaje.text = "Error de secuencia"
		return

	if entrada_actual == secuencia_correcta:
		tiempo_activo = false
		if etiqueta_mensaje: etiqueta_mensaje.text = "¡CÓDIGO CORRECTO!"
		finalizar_exito()
	else:
		intentos -= 1
		if etiqueta_intentos:
			etiqueta_intentos.text = "Intentos: %d" % intentos
		
		if intentos <= 0:
			tiempo_activo = false
			if etiqueta_mensaje: etiqueta_mensaje.text = "¡SIN INTENTOS!"
			btn_confirmar.disabled = true
			await get_tree().create_timer(1.0).timeout
			finalizar_fracaso()
		else:
			_mostrar_mensaje_temporal("¡INCORRECTO!", 2.0, Color.BROWN)
			_on_borrar_pressed()

func _on_btn_ayuda_pressed():
	if aud_ayuda:
		print("AYUDA: Reproduciendo pista de audio...")
		aud_ayuda.play()
		# Opcional: Podrías cambiar el texto del mensaje para indicar que escuche
		_mostrar_mensaje_temporal("¡Escucha la pista con atención!", 3.0, Color.AQUA)

func _on_borrar_pressed():
	# Ahora borra todo el progreso de la entrada actual
	entrada_actual.clear()
	actualizar_visual_entrada()

func _on_salir_pressed():
	cancelar_actividad()
	
func _gestionar_bloqueo_salida(bloquear: bool):
	if bloquear:
		if btn_salir and not btn_salir.disabled:
			btn_salir.disabled = true
			btn_salir.modulate = Color(1, 1, 1, 0.3) # Se vuelve transparente
			habilitar_esc = false # Desactiva la tecla ESC (de ActividadBase)
			print("SISTEMA: Salida bloqueada por tiempo crítico.")
	else:
		if btn_salir and btn_salir.disabled:
			btn_salir.disabled = false
			btn_salir.modulate = Color(1, 1, 1, 1.0) # Vuelve a la normalidad
			habilitar_esc = true # Reactiva la tecla ESC
	
func _mostrar_mensaje_temporal(nuevo_texto: String, duracion: float = 3.0, color: Color = Color.WHITE) -> void:
	if etiqueta_mensaje:
		var color_original = etiqueta_mensaje.modulate
		etiqueta_mensaje.text = nuevo_texto
		etiqueta_mensaje.modulate = color # Cambiamos el color
		
		await get_tree().create_timer(duracion).timeout
		
		if tiempo_activo and etiqueta_mensaje:
			etiqueta_mensaje.text = _texto_pendiente
			etiqueta_mensaje.modulate = color_original # Restauramos color
			
func _preparar_barra_estilo():
	if not barra_tiempo: return
	
	# 1. Estilo del Fondo (Lo que queda vacío)
	var estilo_bg = StyleBoxFlat.new()
	estilo_bg.bg_color = Color(0.1, 0.1, 0.1, 1.0) # Gris casi negro
	estilo_bg.draw_center = true
	# CAMBIO: Usamos el método set_border_width_all()
	estilo_bg.set_border_width_all(2) 
	estilo_bg.border_color = Color.WHITE 
	estilo_bg.set_corner_radius_all(4)
	
	# 2. Estilo del Relleno (La parte que baja)
	var estilo_fill = StyleBoxFlat.new()
	estilo_fill.bg_color = Color.WHITE 
	estilo_fill.set_corner_radius_all(4)
	# CAMBIO: Usamos el método set_border_width_all()
	estilo_fill.set_border_width_all(1) 
	estilo_fill.border_color = Color(0, 0, 0, 0.2) 
	
	# 3. Aplicar overrides
	barra_tiempo.add_theme_stylebox_override("background", estilo_bg)
	barra_tiempo.add_theme_stylebox_override("fill", estilo_fill)
