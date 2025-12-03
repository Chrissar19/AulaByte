extends ActividadBase
class_name Actividad7

var asignaciones: Dictionary = {}
var zonas_correctas := { "archivo": "archivo", "programa": "programa", "cpu": "cpu", "so": "so" }
@onready var btn_salir: Button = $UI/BtnSalir
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	super._ready()
	
	btn_salir.pressed.connect(_on_btn_salir_pressed)

func _on_element_asigned(categoria: String, zona: String) -> void:
	asignaciones[categoria] = zona
	if asignaciones.size() < zonas_correctas.size():
		return
		
	_validar_asignaciones()

func _validar_asignaciones() -> void:
	var todos_correctos := true
	for categoria in zonas_correctas.keys():
		if not asignaciones.has(categoria) or asignaciones[categoria] != zonas_correctas[categoria]:
			todos_correctos = false
			break

	if todos_correctos:
		finalizar_exito()
	else:
		finalizar_fracaso()

func _on_archivo_element_asigned(categoria: String, zona: String) -> void:
	_on_element_asigned(categoria, zona)

func _on_programa_element_asigned(categoria: String, zona: String) -> void:
	_on_element_asigned(categoria, zona)

func _on_cpu_element_asigned(categoria: String, zona: String) -> void:
	_on_element_asigned(categoria, zona)

func _on_so_element_asigned(categoria: String, zona: String) -> void:
	_on_element_asigned(categoria, zona)
	
func _on_btn_salir_pressed() -> void:
	cancelar_actividad()


func _on_button_pressed() -> void:
	audio_stream_player.play()
