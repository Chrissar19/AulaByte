extends Control

@onready var img_personaje: TextureRect = $VBoxContainer/ImagenPersonaje
@onready var lbl_nombre: Label = $VBoxContainer/NombrePersonaje
@onready var lbl_vidas: Label = $VBoxContainer/Vidas
@onready var lbl_puntos: Label = $VBoxContainer/Puntos
@onready var lbl_tiempo_nivel: Label = $VBoxContainer/TiempoNivel

func _ready() -> void:
	var info: personajeInfo = JugadorSeleccionado.get_info()
	var tiempo = JugadorSeleccionado.get_tiempo()
	lbl_tiempo_nivel.text = "Tiempo: " + str(tiempo as int) + "s"
	
	if info:
		img_personaje.texture = info.sprite
		lbl_nombre.text = info.nombre
	else:
		lbl_nombre.text = "Sin personaje"
		
	#-- Valores de prueba
	lbl_vidas.text = "Vidas: 3"
	lbl_puntos.text = "Puntos: 0"
	
	#-- Esperar un momento y luego ir a nivel
	await get_tree().create_timer(2.5).timeout
	get_tree().change_scene_to_file("res://escenas/niveles/nivel_tuto.tscn")
