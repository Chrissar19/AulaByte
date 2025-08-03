extends Control

#--------------------------------------------------------------------------------
# Referencias de nodos de la UI (se resuelven en _ready)
#--------------------------------------------------------------------------------
@onready var img_personaje: TextureRect = $VBoxContainer/ImagenPersonaje
@onready var lbl_nombre: Label = $VBoxContainer/NombrePersonaje
@onready var lbl_vidas: Label = $VBoxContainer/Vidas
@onready var lbl_puntos: Label = $VBoxContainer/Puntos
@onready var lbl_tiempo_nivel: Label = $VBoxContainer/TiempoNivel

#--------------------------------------------------------------------------------
# Al iniciar la pantalla de carga, mostrar datos del personaje y cargar nivel
#--------------------------------------------------------------------------------
func _ready() -> void:
	var info: personajeInfo = JugadorSeleccionado.get_info()
	var tiempo: float = JugadorSeleccionado.get_tiempo()
	
	_mostrar_datos(info, tiempo)
	
	await get_tree().create_timer(2.5).timeout
	_cargar_nivel()

#--------------------------------------------------------------------------------
# Muestra los datos en pantalla
#--------------------------------------------------------------------------------
func _mostrar_datos(info: personajeInfo, tiempo: float) -> void:
	lbl_tiempo_nivel.text = "Tiempo: %ds" % int(tiempo)
	
	if info:
		img_personaje.texture = info.sprite
		lbl_nombre.text = info.nombre
	else:
		lbl_nombre.text = "Sin personaje"
	
	lbl_vidas.text = "Vidas: 3"  # <- Puedes actualizar luego con un sistema real
	lbl_puntos.text = "Puntos: 0"

#--------------------------------------------------------------------------------
# Cambia a la escena del primer nivel
#--------------------------------------------------------------------------------
func _cargar_nivel() -> void:
	get_tree().change_scene_to_file("res://escenas/niveles/nivel_tuto.tscn")
