extends Control

#--------------------------------------------------------------------------------
# Referencias de nodos de la UI (se resuelven en _ready)
#--------------------------------------------------------------------------------
@onready var img_personaje: TextureRect = $VBoxContainer/ImagenPersonaje
@onready var lbl_nombre: Label = $VBoxContainer/NombrePersonaje
@onready var lbl_vidas: Label = $VBoxContainer/Vidas
@onready var lbl_puntos: Label = $VBoxContainer/Puntos
@onready var lbl_tiempo_nivel: Label = $VBoxContainer/TiempoNivel
@onready var barra_progreso: ProgressBar = $BarraProgreso

var progreso: float = 0.0
var tiempo_inicio: float
var tiempo_min_carga: float = 2.5

#--------------------------------------------------------------------------------
# Al iniciar la pantalla de carga, mostrar datos del personaje y cargar nivel
#--------------------------------------------------------------------------------
func _ready() -> void:
	tiempo_inicio = Time.get_ticks_msec()
	
	var info: personajeInfo = GameManager.get_personaje()
	var tiempo: float = GameManager.get_tiempo()
	var vidas: int = GameManager.get_vidas()
	var puntos: int = GameManager.get_puntos()
	
	_mostrar_datos(info, tiempo, vidas, puntos)
	precargar_nivel()

#--------------------------------------------------------------------------------
# Muestra los datos en pantalla
#--------------------------------------------------------------------------------
func _mostrar_datos(info: personajeInfo, tiempo: float, vidas: int, puntos: int) -> void:
	lbl_tiempo_nivel.text = "Tiempo: %ds" % int(tiempo)
	
	if info:
		img_personaje.texture = info.sprite
		lbl_nombre.text = info.nombre
	else:
		lbl_nombre.text = "Sin personaje"
	
	lbl_vidas.text = "Vidas: %d" % vidas
	lbl_puntos.text = "Puntos: %d" % puntos

#--------------------------------------------------------------------------------
# Precargar nivel
#--------------------------------------------------------------------------------
func precargar_nivel() -> void:
	var siguiente_nivel := GameManager.get_nivel_actual()
	if siguiente_nivel:
		ResourceLoader.load_threaded_request(siguiente_nivel.resource_path)
		
		#-- Esperar que se complete la carga
		while true:
			var estado = ResourceLoader.load_threaded_get_status(siguiente_nivel.resource_path, [progreso])
			match estado:
				ResourceLoader.THREAD_LOAD_LOADED:
					break
				ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
					push_error("Recurson no valido: " + siguiente_nivel.resource_path)
					break
				ResourceLoader.THREAD_LOAD_FAILED:
					push_error("Error al cargar: " + siguiente_nivel.resource_path)
					break
			#-- Actualizar barra
			barra_progreso.value = progreso * 100
			await  get_tree().process_frame
		
		#-- Esperar tiempo minimo
		var tiempo_transcurrido = (Time.get_ticks_msec() - tiempo_inicio) / 1000.0
		var tiempo_restante = tiempo_min_carga - tiempo_transcurrido
		if tiempo_restante > 0:
			await get_tree().create_timer(tiempo_restante).timeout
			
		_cargar_nivel()
	
	else:
		get_tree().change_scene_to_file("res://escenas/menu/creditos.tscn")
		

#--------------------------------------------------------------------------------
# Cambiar escena
#--------------------------------------------------------------------------------
func _cargar_nivel() -> void:
	var siguiente_nivel = GameManager.get_nivel_actual()
	if siguiente_nivel:
		var nivel_cargado = ResourceLoader.load_threaded_get(siguiente_nivel.resource_path)
		if nivel_cargado:
			get_tree().change_scene_to_packed(nivel_cargado)
		else:
			#-- Fallback
			get_tree().change_scene_to_packed(siguiente_nivel)
	else:
		print("No hay mas niveles")
		get_tree().change_scene_to_file("res://escenas/menu/menu_principal.tscn")
