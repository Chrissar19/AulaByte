extends ActividadBase
class_name Actividad7

@onready var btn_salir: Button = $UI/BtnSalir
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var ctrl_tiempo: ControlTiempo = $UI/ControlTiempo
@onready var descripcion_act: Label = $"UI/descripcion act"
@onready var lbl_intentos: Label = $UI/LblIntentos

@export var tiempo_maximo: float = 45.0
@export var intentos: int = 3 

const MSJ_ORIGINAL := "Arrastra cada eleménto para\nreparar la cpu."
var asignaciones: Dictionary = {}
var zonas_correctas := { "archivo": "archivo", "programa": "programa", "cpu": "cpu", "so": "so" }

func _ready() -> void:
	super._ready()
	descripcion_act.text = MSJ_ORIGINAL
	lbl_intentos.text = "Intentos: %d" % intentos
	
	ctrl_tiempo.vincular_ui(descripcion_act, btn_salir, func(h): habilitar_esc = h)
	ctrl_tiempo.tiempo_agotado.connect(_on_tiempo_agotado)
	ctrl_tiempo.iniciar(tiempo_maximo)
	
	btn_salir.pressed.connect(_on_salir_pressed)

func _on_element_asigned(categoria: String, zona: String) -> void:
	if _finalizado: return
	asignaciones[categoria] = zona
	if asignaciones.size() >= zonas_correctas.size():
		_validar_asignaciones()

func _validar_asignaciones() -> void:
	var todos_correctos := true
	for categoria in zonas_correctas.keys():
		if asignaciones.get(categoria) != zonas_correctas[categoria]:
			todos_correctos = false
			break

	if todos_correctos:
		_ganar()
	else:
		_manejar_error()

func _manejar_error() -> void:
	intentos -= 1
	lbl_intentos.text = "Intentos: %d" % intentos
	
	if intentos <= 0:
		_perder()
	else:
		# Resetea el registro interno
		asignaciones.clear()
		# Reseteamos OBJETOS FISICAMENTE
		get_tree().call_group("elementos_act7", "reset_position")
		# Muestra el mensaje
		_mostrar_mensaje_temporal("Orden incorrecto", 2.0, Color.TOMATO)

# --- FIN ALIZACIÓN ---
func _ganar():
	ctrl_tiempo.detener()
	descripcion_act.text = "¡CPU Reparada con éxito!"
	descripcion_act.modulate = Color.CYAN
	finalizar_exito()

func _perder():
	ctrl_tiempo.detener()
	lbl_intentos.text = "¡Sin intentos!"
	lbl_intentos.modulate = Color.RED
	finalizar_fracaso()

func _on_tiempo_agotado():
	_perder()

func _mostrar_mensaje_temporal(nuevo_texto: String, duracion: float, color: Color) -> void:
	if descripcion_act:
		var color_original = descripcion_act.modulate
		descripcion_act.text = nuevo_texto
		descripcion_act.modulate = color
		await get_tree().create_timer(duracion).timeout
		if not _finalizado and descripcion_act:
			descripcion_act.text = MSJ_ORIGINAL
			descripcion_act.modulate = color_original

# --- SEÑALES ---
func _on_archivo_element_asigned(cat, zon): _on_element_asigned(cat, zon)
func _on_programa_element_asigned(cat, zon): _on_element_asigned(cat, zon)
func _on_cpu_element_asigned(cat, zon): _on_element_asigned(cat, zon)
func _on_so_element_asigned(cat, zon): _on_element_asigned(cat, zon)

func _on_salir_pressed():
	ctrl_tiempo.detener()
	cancelar_actividad()

func _on_button_pressed():
	if audio_stream_player.playing: return
	ctrl_tiempo.pausar(true)
	audio_stream_player.play()
	await audio_stream_player.finished
	if not _finalizado: ctrl_tiempo.pausar(false)
