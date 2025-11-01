extends TextureRect
class_name ImagenArrastrable2

@export var categorias: Array[String] = ["ElementoEntrada"]

@onready var contenedor_objetos: Control = $".."
@onready var zona_elementos_salida: ZonaCPU = $"../../Zonas/ZonaElementosSalida"
@onready var zona_partes_computador: ZonaCPU = $"../../Zonas/ZonaPartesComputador"
@onready var zona_elementos_entrada: ZonaCPU = $"../../Zonas/ZonaElementosEntrada"
@onready var zona_archivos_digitales: ZonaCPU = $"../../Zonas/ZonaArchivosDigitales"
@onready var zona_componentes_internos: ZonaCPU = $"../../Zonas/ZonaComponentesInternos"

signal retornar
signal element_asigned(categorias: Array[String], zona: String)

var _drag_activo := false
var vista: TextureRect = null
var _posicion_inicial: Vector2
var _car_random := RandomNumberGenerator.new()
var _posicion_final_drag: Vector2 = Vector2.ZERO

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_posicion_inicial = position
	_car_random.randomize()

func _get_drag_data(at_position: Vector2) -> Variant:
	_drag_activo = true
	
	var data := {
		"from": self,
		"categorias": categorias,
		"type": "draggable_obj",
		"at_position": at_position
	}
	
	vista = TextureRect.new()
	vista.texture = texture
	vista.size = size
	vista.scale = scale
	vista.modulate.a = 0.2
	vista.expand_mode = expand_mode
	vista.stretch_mode = stretch_mode
	vista.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var preview_size: Vector2 = size * scale
	vista.position = -preview_size * 0.5
	
	var wrapper := Control.new()
	wrapper.name = "DragPreviewWrapper"
	wrapper.size = preview_size
	wrapper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrapper.add_child(vista)

	set_drag_preview(wrapper)
	
	return data

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		if not _drag_activo:
			return
		
		_drag_activo = false
		_posicion_final_drag = get_viewport().get_mouse_position()

		if is_queued_for_deletion():
			return

		var zonas = {
			"ElementoSalida": zona_elementos_salida,
			"PartesComputador": zona_partes_computador,
			"ElementoEntrada": zona_elementos_entrada,
			"ArchivosDigitales": zona_archivos_digitales,
			"ComponentesInternos": zona_componentes_internos
		}

		var zona_correcta := ""
		var zona_destino: ZonaCPU = null

		for nombre_zona in zonas.keys():
			var zona = zonas[nombre_zona]
			if not zona:
				continue

			if _esta_sobre_zona(zona):
				zona_correcta = nombre_zona
				zona_destino = zona
				break

		if zona_correcta != "" and zona_destino:
			var id_elemento := str(name)
			if not zona_destino.has_element(id_elemento):
				_clonar_en_zona(zona_destino)
				zona_destino.add_element(id_elemento)
				emit_signal("element_asigned", categorias, zona_correcta)
			else:
				print("⚠️ El elemento ya existe en esta zona.")
				volver_a_empezar()
		else:
			volver_a_empezar()

func volver_a_empezar() -> void:
	position = _posicion_inicial
	emit_signal("retornar")

func _esta_sobre_zona(zona: Control) -> bool:
	if not zona:
		return false
		
	var rect_zona = zona.get_global_rect()
	return rect_zona.has_point(_posicion_final_drag)

func _clonar_en_zona(zona: Control) -> void:
	var copia := duplicate() as ImagenArrastrable2
	zona.add_child(copia)

	await get_tree().process_frame
	
	var preview_size: Vector2 = copia.size * copia.scale
	copia.global_position = _posicion_final_drag - (preview_size * 0.5)
	copia.mouse_filter = Control.MOUSE_FILTER_IGNORE
	copia.visible = true

func ocultar_elemento() -> void:
	visible = false
