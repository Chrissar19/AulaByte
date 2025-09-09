extends Control

@onready var img_personaje: TextureRect = $VBoxContainer/ImagenPersonaje
@onready var lbl_nombre: Label = $VBoxContainer/NombrePersonaje
@onready var lbl_vidas: Label = $VBoxContainer/Vidas
@onready var lbl_puntos: Label = $VBoxContainer/Puntos
@onready var lbl_tiempo_nivel: Label = $VBoxContainer/TiempoNivel
@onready var barra_progreso: ProgressBar = $BarraProgreso

var progreso: float = 0.0
var tiempo_inicio: float

func _ready() -> void:
	tiempo_inicio = Time.get_ticks_msec()
	var info = GameManager.get_personaje()
	var tiempo: float = GameManager.get_tiempo()
	var vidas: int = GameManager.get_vidas()
	var puntos: int = GameManager.get_puntos()
	_mostrar_datos(info, tiempo, vidas, puntos)
	precargar_nivel()

func _mostrar_datos(info, tiempo: float, vidas: int, puntos: int) -> void:
	lbl_tiempo_nivel.text = "Tiempo: %ds" % int(tiempo)
	if info:
		img_personaje.texture = info.sprite
		lbl_nombre.text = info.nombre
	else:
		lbl_nombre.text = "Sin personaje"
	lbl_vidas.text = "Vidas: %d" % vidas
	lbl_puntos.text = "Puntos: %d" % puntos

func precargar_nivel() -> void:
	var siguiente_nivel := GameManager.get_nivel_actual()
	if siguiente_nivel:
		# pedimos precarga en hilo
		ResourceLoader.load_threaded_request(siguiente_nivel.resource_path)
		progreso = 0.0
		# Polling: esperamos hasta que ResourceLoader devolvió el recurso
		while true:
			var nivel_cargado = ResourceLoader.load_threaded_get(siguiente_nivel.resource_path)
			if nivel_cargado:
				progreso = 1.0
				barra_progreso.value = progreso * 100
				break
			# aumentamos progreso "simulado" hasta 95% para que la barra se mueva
			progreso = min(0.95, progreso + 0.02)
			barra_progreso.value = progreso * 100

		# esperar tiempo mínimo de pantalla (ej. 2.5 segundos en total)
		var tiempo_transcurrido = (Time.get_ticks_msec() - tiempo_inicio) / 1000.0
		if tiempo_transcurrido < 2.5:
			await get_tree().create_timer(2.5 - tiempo_transcurrido).timeout

		_cargar_nivel()
	else:
		get_tree().change_scene_to_file("res://escenas/menu/creditos.tscn")

func _cargar_nivel() -> void:
	var siguiente_nivel = GameManager.get_nivel_actual()
	if siguiente_nivel:
		var nivel_cargado = ResourceLoader.load_threaded_get(siguiente_nivel.resource_path)
		if nivel_cargado:
			get_tree().change_scene_to_packed(nivel_cargado)
		else:
			# fallback
			get_tree().change_scene_to_packed(siguiente_nivel)
	else:
		print("No hay mas niveles")
		get_tree().change_scene_to_file("res://escenas/menu/menu_principal.tscn")
