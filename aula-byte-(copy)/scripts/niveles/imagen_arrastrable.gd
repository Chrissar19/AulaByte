extends TextureRect
class_name ImagenArrastrable

@export_enum("archivo", "programa", "cpu", "so") var categoria: String = "archivo"

@onready var contenedor_objetos: Control = $".."
@onready var zona_so: ZonaCPU = $"../../ZonaConsola/ZonaSO"
@onready var zona_cpu: ZonaCPU = $"../../ZonaConsola/ZonaCPU"
@onready var zona_archivo: ZonaCPU = $"../../ZonaConsola/ZonaArchivo"
@onready var zona_programa: ZonaCPU = $"../../ZonaConsola/ZonaPrograma"

signal retornar
signal element_asigned(categoria: String, zona: String)

var _bloqueado := false
var _drag_activo := false
var vista: TextureRect = null
var _posicion_inicial: Vector2
var _car_ramdon := RandomNumberGenerator.new()
var _posicion_final_drag: Vector2 = Vector2.ZERO

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_posicion_inicial = position
	_car_ramdon.randomize()

func _get_drag_data(at_position: Vector2) -> Variant:
	if _bloqueado:
		return null

	_drag_activo = true

	var data := {
		"from": self,
		"categoria": categoria,
		"type": "draggable_obj",
		"at_position": at_position
	}
	
	vista = TextureRect.new()
	vista.texture = texture
	vista.size = size
	vista.scale = scale
	vista.modulate.a = 0.6
	vista.expand_mode = expand_mode
	vista.stretch_mode = stretch_mode

	set_drag_preview(vista)
	visible = false

	return data

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		if not _drag_activo:
			return
		
		_drag_activo = false
		_posicion_final_drag = get_viewport().get_mouse_position()
		
		if is_queued_for_deletion() or _bloqueado:
			return

		var zona_correcta := ""
		var zonas = { "archivo": zona_archivo, "programa": zona_programa, "cpu": zona_cpu, "so": zona_so}

		for nombre_zona in zonas.keys():
			var zona = zonas[nombre_zona]
			if not zona:
				continue

			if _esta_sobre_zona(zona):
				if zona.get_is_loked():
					volver_a_empezar()
					return
				else:
					zona_correcta = nombre_zona
					_fijar_en_zona(zona)
					break

		if zona_correcta != "":
			emit_signal("element_asigned", categoria, zona_correcta)
		else:
			volver_a_empezar()

func volver_a_empezar() -> void:
	visible = true
	if get_parent() != contenedor_objetos:
		get_parent().remove_child(self)
		contenedor_objetos.add_child(self)
	position = _posicion_inicial
	emit_signal("retornar")

func _esta_sobre_zona(zona: Control) -> bool:
	if not zona:
		return false
		
	var rect_zona = zona.get_global_rect()
	var dentro = rect_zona.has_point(_posicion_final_drag)
	
	return dentro

func _fijar_en_zona(zona: Control) -> void:
	var pos_global_actual = global_position
	get_parent().remove_child(self)
	zona.add_child(self)

	await get_tree().process_frame

	global_position = pos_global_actual
	position = (zona.size - size) / 2
	position.y += 20
	size = zona.size

	_bloqueado = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	if zona.has_method("set_is_loked"):
		zona.set_is_loked(true)

	visible = true
