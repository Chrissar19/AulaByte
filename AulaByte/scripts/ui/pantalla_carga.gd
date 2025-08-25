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
	var info: personajeInfo = GameManager.get_personaje()
	var tiempo: float = GameManager.get_tiempo()
	var vidas: int = GameManager.get_vidas()
	var puntos: int = GameManager.get_puntos()
	
	_mostrar_datos(info, tiempo, vidas, puntos)
	
	await get_tree().create_timer(2.5).timeout
	_cargar_nivel()

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
# Cambia a la escena del primer nivel
#--------------------------------------------------------------------------------
func _cargar_nivel() -> void:
	var siguiente_nivel := GameManager.get_nivel_actual()
	if siguiente_nivel:
		get_tree().change_scene_to_packed(siguiente_nivel)
	else:
		print("No hay mas niveles")
		get_tree().change_scene_to_file("res://escenas/menu/menu_principal.tscn")
