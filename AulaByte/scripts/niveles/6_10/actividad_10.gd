extends ActividadBase
class_name Actividad10

@onready var contenedor_botones: GridContainer = $ContenedorBotones
@onready var entrada_container: HBoxContainer = $Slots
@onready var btn_reiniciar: Button = $UI/BtnCancelar
@onready var btn_confirmar: Button = $UI/BtnConfirmar
@onready var btn_borrar: Button = $UI/BtnBorrar
@onready var etiqueta_mensaje: Label = $EtiquetaMensaje

var secuencia_correcta: Array = [] # Recibirá [1, 3, 2...]
var entrada_actual: Array = []   # Guardará [1, 3, 2...]
var _texto_pendiente: String = "Ingresa la secuencia"

# Diccionario Maestro de IDs
const COLORES_ID = {
	1: "azul", 2: "amarilla", 3: "roja", 
	4: "morada", 5: "verde", 6: "rosa", 7: "naranja"
}

func _ready():
	super._ready()
	
	# Aplicamos el texto que guardamos en la configuración
	if etiqueta_mensaje:
		etiqueta_mensaje.text = _texto_pendiente
	
	for child in contenedor_botones.get_children(): child.free()
	
	for id in COLORES_ID.keys():
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(70, 70)
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
		btn.pressed.connect(_on_color_pressed.bind(id))
		contenedor_botones.add_child(btn)
	
	btn_confirmar.pressed.connect(_on_confirmar_pressed)
	btn_borrar.pressed.connect(_on_borrar_pressed)
	btn_reiniciar.pressed.connect(_on_reiniciar_pressed)

func configurar_con_parametros(parametros: Dictionary) -> void:
	if parametros.has("codigo"):
		secuencia_correcta = parametros.codigo
		# EN LUGAR DE ASIGNAR AL LABEL DIRECTO:
		_texto_pendiente = "Ingresa la secuencia de %d colores" % secuencia_correcta.size()
		
		# Si por casualidad el nodo YA está listo, lo actualizamos de una vez
		if etiqueta_mensaje:
			etiqueta_mensaje.text = _texto_pendiente
			
		print("ACTIVIDAD: Código ID recibido: ", secuencia_correcta)

func _on_color_pressed(id: int):
	# Si la secuencia no cargó, permitimos hasta 10 para testear
	var limite = secuencia_correcta.size() if secuencia_correcta.size() > 0 else 10
	
	if entrada_actual.size() < limite:
		entrada_actual.append(id)
		actualizar_visual_entrada()
		print("ACTIVIDAD: Añadido ID ", id, ". Entrada: ", entrada_actual)

func actualizar_visual_entrada():
	# Siempre verificar si el contenedor existe antes de limpiar
	if not entrada_container: return
	
	for child in entrada_container.get_children(): child.free()
	for id in entrada_actual:
		var rect = ColorRect.new()
		rect.custom_minimum_size = Vector2(60, 60)
		rect.color = _color_from_id(id)
		entrada_container.add_child(rect)

func _color_from_id(id: int) -> Color:
	match id:
		1: return Color(0, 0.6, 1)    # Azul
		2: return Color(1, 0.8, 0)    # Amarilla
		3: return Color(0.8, 0.1, 0.1) # Roja
		4: return Color(0.5, 0, 0.8)   # Morada
		5: return Color(0.2, 0.8, 0.2) # Verde
		6: return Color(1, 0.3, 0.6)   # Rosa
		7: return Color(1, 0.5, 0)     # Naranja
	return Color.WHITE

func _on_confirmar_pressed():
	if secuencia_correcta.size() == 0:
		if etiqueta_mensaje: etiqueta_mensaje.text = "Error: Sin secuencia del nivel"
		return

	if entrada_actual == secuencia_correcta:
		if etiqueta_mensaje: etiqueta_mensaje.text = "¡CÓDIGO CORRECTO!"
		finalizar_exito()
	else:
		if etiqueta_mensaje: etiqueta_mensaje.text = "¡INCORRECTO!"
		_on_reiniciar_pressed()

func _on_borrar_pressed():
	if entrada_actual.size() > 0:
		entrada_actual.pop_back()
		actualizar_visual_entrada()

func _on_reiniciar_pressed():
	entrada_actual.clear()
	actualizar_visual_entrada()
