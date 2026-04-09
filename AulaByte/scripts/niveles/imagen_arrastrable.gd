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
var _size_inicial: Vector2 
var _posicion_final_drag: Vector2 = Vector2.ZERO

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_posicion_inicial = position
	_size_inicial = size 
	add_to_group("elementos_act7")

# --- FUNCIÓN DE RESET (MÁS AGRESIVA) ---
func reset_position() -> void:
	_bloqueado = false
	_drag_activo = false
	
	# 1. Si está en una zona, liberarla
	var padre_actual = get_parent()
	if padre_actual is ZonaCPU:
		padre_actual.set_is_loked(false)
		padre_actual.remove_child(self)
		contenedor_objetos.add_child(self)
	
	# 2. Resetear estado físico y visual
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = true
	position = _posicion_inicial
	size = _size_inicial

func _get_drag_data(at_position: Vector2) -> Variant:
	if _bloqueado: return null
	_drag_activo = true
	
	vista = TextureRect.new()
	vista.texture = texture
	vista.size = size
	vista.modulate.a = 0.6
	set_drag_preview(vista)
	visible = false
	return {"from": self, "categoria": categoria, "type": "draggable_obj"}

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		if not _drag_activo: return
		_drag_activo = false
		_posicion_final_drag = get_viewport().get_mouse_position()
		
		if is_queued_for_deletion() or _bloqueado: return

		var zonas = { "archivo": zona_archivo, "programa": zona_programa, "cpu": zona_cpu, "so": zona_so}
		for nombre_zona in zonas.keys():
			var zona = zonas[nombre_zona]
			if zona and _esta_sobre_zona(zona) and not zona.get_is_loked():
				_fijar_en_zona(zona)
				emit_signal("element_asigned", categoria, nombre_zona)
				return
		volver_a_empezar()

func volver_a_empezar() -> void:
	#print("SISTEMA: Retornando al inicio por drop inválido")
	if get_parent() != contenedor_objetos:
		var padre = get_parent()
		if padre is ZonaCPU: padre.set_is_loked(false)
		padre.remove_child(self)
		contenedor_objetos.add_child(self)
	
	visible = true
	position = _posicion_inicial
	size = _size_inicial
	_bloqueado = false
	mouse_filter = Control.MOUSE_FILTER_STOP

func _esta_sobre_zona(zona: Control) -> bool:
	return zona.get_global_rect().has_point(_posicion_final_drag)

func _fijar_en_zona(zona: Control) -> void:
	var pos_global_actual = global_position
	get_parent().remove_child(self)
	zona.add_child(self)

	# Espera un frame para que Godot actualice posiciones
	await get_tree().process_frame

	if _bloqueado or get_parent() != zona: 
		#print("DEBUG: Abortando fijado de ", categoria, " por reset externo.")
		return 

	global_position = pos_global_actual
	position = (zona.size - size) / 2
	position.y += 20

	_bloqueado = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	zona.set_is_loked(true)
	visible = true
