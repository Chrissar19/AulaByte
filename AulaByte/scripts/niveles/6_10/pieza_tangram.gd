extends Sprite2D
class_name PiezaTangram

signal soltar(global_pos: Vector2)

@export var color_objetivo: Color
@export var draggable: bool = true
@export var rot_step_deg: float = 15.0

var _arrastrando := false
var _offset := Vector2.ZERO
# Cambiamos Actividad6 por Node o ActividadBase para evitar el error circular
var _actividad: Node 

func _ready() -> void:
	# Al quitar "as Actividad6", Godot ya no busca esa clase específica al compilar este script
	_actividad = get_tree().get_first_node_in_group("Actividad6")
	if _actividad == null:
		_actividad = get_parent().get_parent()

func _input(event: InputEvent) -> void:
	if not draggable:
		return
		
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		
		if not _sobre_mi():
			return
			
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.double_click:
				_ejecutar_rotacion()
				return 

			if mb.pressed:
				_arrastrando = true
				_offset = global_position - get_global_mouse_position()
				z_index = 50
				get_viewport().set_input_as_handled()
			elif not mb.pressed and _arrastrando:
				_arrastrando = false
				# Godot buscará el método "intentar_colocar" en tiempo de ejecución
				if is_instance_valid(_actividad) and _actividad.has_method("intentar_colocar"):
					_actividad.intentar_colocar(self, color_objetivo)
				get_viewport().set_input_as_handled()
		
		elif mb.pressed and (mb.button_index == MOUSE_BUTTON_WHEEL_UP or mb.button_index == MOUSE_BUTTON_WHEEL_DOWN):
			var dir := 1.0 if mb.button_index == MOUSE_BUTTON_WHEEL_UP else -1.0
			rotation_degrees += dir * rot_step_deg
			get_viewport().set_input_as_handled()
	
	elif event is InputEventKey:
		if not _sobre_mi():
			return
		if event.pressed and not event.echo:
			if event.keycode == KEY_E:
				_ejecutar_rotacion()
				get_viewport().set_input_as_handled()

func _ejecutar_rotacion() -> void:
	var nueva_rot = round((rotation_degrees + rot_step_deg) / rot_step_deg) * rot_step_deg
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees", nueva_rot, 0.1).set_trans(Tween.TRANS_SINE)

func _process(_dt: float) -> void:
	if _arrastrando:
		global_position = get_global_mouse_position() + _offset

func _sobre_mi() -> bool:
	var vp := get_viewport()
	var mouse := vp.get_mouse_position()
	var lp := to_local(mouse)
	
	var tam_texture := Vector2.ZERO
	if texture != null:
		tam_texture = texture.get_size() * scale
	else:
		tam_texture = Vector2(64, 64)
		
	var rect := Rect2(-tam_texture / 2, tam_texture)
	return rect.has_point(lp)
