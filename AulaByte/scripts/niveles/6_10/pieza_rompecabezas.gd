extends TextureRect
class_name PiezaRompecabezas

signal drop_request(pieza: TextureRect)

@export var index: int = 0
var _dragging: bool = false
var _grab_offset: Vector2 = Vector2.ZERO
var _start_parent: Node = null
var _start_pos_local: Vector2 = Vector2.ZERO
var _callback: Callable
var _locked: bool = false

func _setup(p_index: int, size_hint: Vector2, on_drop: Callable) -> void:
	index = p_index
	size = size_hint
	_callback = on_drop
	_start_parent = get_parent()
	_start_pos_local = position

	mouse_filter = Control.MOUSE_FILTER_STOP  # recibe el click
	focus_mode = Control.FOCUS_NONE
	z_as_relative = false
	set_as_top_level(false)

func _gui_input(event: InputEvent) -> void:
	if _locked:
		return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				print("CLICK pieza ", index)
				_dragging = true
				set_as_top_level(true)
				_grab_offset = get_viewport().get_mouse_position() - position
				z_index = 100
			else:
				_dragging = false
				z_index = 0
				if _callback and _callback.is_valid():
					_callback.call(self)

	elif event is InputEventMouseMotion and _dragging:
		position = get_viewport().get_mouse_position() - _grab_offset


func fall_back() -> void:
	# Regresa a su contenedor original y a su posición de inicio local
	if is_instance_valid(_start_parent) and _start_parent != get_parent():
		reparent(_start_parent)
	set_as_top_level(false)
	position = _start_pos_local

func lock_in_place() -> void:
	_locked = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_as_top_level(false)
	_start_parent = get_parent()
	_start_pos_local = position
