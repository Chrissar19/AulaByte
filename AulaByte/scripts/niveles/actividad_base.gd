extends Control
class_name ActividadBase

# Contrato común
signal resuelto(exito: bool)  # true = éxito, false = fallo (penaliza según GameManager)
signal cancelado               # salir sin penalización
signal cancelar                # alias (compatibilidad con minijuegos existentes)

@export var habilitar_esc: bool = true
@export var crear_boton_si_no_existe: bool = true
@export var texto_boton_salir: String = "Salir"
@export var exit_button_path: NodePath  # opcional: si tu botón no está en UI/BtnSalir

var _finalizado: bool = false
@onready var _btn_salir: Button = _find_exit_button()

func _ready() -> void:
	set_process_unhandled_input(habilitar_esc)

	# Si no hay botón y está permitido, se crea uno básico
	if not is_instance_valid(_btn_salir) and crear_boton_si_no_existe:
		_btn_salir = _create_exit_button()

	if is_instance_valid(_btn_salir):
		_btn_salir.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		_btn_salir.mouse_filter = Control.MOUSE_FILTER_STOP
		_btn_salir.focus_mode = Control.FOCUS_CLICK
		_btn_salir.disabled = false
		_btn_salir.pressed.connect(_on_btn_salir_pressed)

# =========================================================
# ESTADOS DE VICTORIA O FALLA
# =========================================================
func finalizar_exito() -> void:
	if _finalizado: return
	_finalizado = true
	resuelto.emit(true)

func finalizar_fracaso() -> void:
	if _finalizado: return
	_finalizado = true
	resuelto.emit(false)

func cancelar_actividad() -> void:
	if _finalizado: return
	_finalizado = true
	cancelado.emit()
	cancelar.emit()

func _unhandled_input(event: InputEvent) -> void:
	if habilitar_esc and not _finalizado and event.is_action_pressed("ui_cancel"):
		cancelar_actividad()

# =========================================================
# Internos (botón)
# =========================================================
func _on_btn_salir_pressed() -> void:
	cancelar_actividad()

func _find_exit_button() -> Button:
	if exit_button_path != NodePath():
		return get_node_or_null(exit_button_path) as Button
	# Ruta por convención
	return get_node_or_null("UI/BtnSalir") as Button

func _create_exit_button() -> Button:
	var b := Button.new()
	b.text = texto_boton_salir
	add_child(b)
	b.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	b.offset_top = 12
	b.offset_right = -12
	b.size = Vector2(96, 32)
	return b

func configurar_con_parametros(parametros: Dictionary) -> void:
	pass

func limpiar() -> void:
	pass
