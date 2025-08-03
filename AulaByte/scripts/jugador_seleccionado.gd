extends Node

#--------------------------------------------------------------------------------
# Señales de control de vidas
#--------------------------------------------------------------------------------
signal vida_ganada
signal vida_perdida

#--------------------------------------------------------------------------------
# Variables internas del jugador seleccionado
#--------------------------------------------------------------------------------
var id_personaje: int = -1
var info_personaje: personajeInfo = null

var vidas: int = 3
const VIDAS_MAX: int = 5

var puntos: int = 0
var tiempo_nivel_actual: float = 0.0

#--------------------------------------------------------------------------------
# Selección de personaje
#--------------------------------------------------------------------------------
func seleccionar(id: int) -> void:
	id_personaje = id

func set_info(info: personajeInfo) -> void:
	info_personaje = info

func get_info() -> personajeInfo:
	return info_personaje

func obtener_id() -> int:
	return id_personaje

#--------------------------------------------------------------------------------
# Tiempo en el nivel
#--------------------------------------------------------------------------------
func set_tiempo(tiempo: float) -> void:
	tiempo_nivel_actual = tiempo

func get_tiempo() -> float:
	return tiempo_nivel_actual

#--------------------------------------------------------------------------------
# Manejo de puntos
#--------------------------------------------------------------------------------
func agregar_puntos(cantidad: int) -> void:
	puntos += cantidad

func reiniciar_puntos() -> void:
	puntos = 0

func get_puntos() -> int:
	return puntos

#--------------------------------------------------------------------------------
# Manejo de vidas
#--------------------------------------------------------------------------------
func perder_vida() -> void:
	if vidas <= 0:
		return
		
	vidas -= 1
	emit_signal("vida_perdida")
	
	if vidas <= 0:
		_morir()

func ganar_vida() -> void:
	if vidas < VIDAS_MAX:
		vidas += 1
		emit_signal("vida_ganada")

func reiniciar_vidas() -> void:
	vidas = 3

func get_vidas() -> int:
	return vidas

func _morir() -> void:
	get_tree().change_scene_to_file("res://escenas/menu/menu_perder.tscn")
	
#--------------------------------------------------------------------------------
# Recibir daño desde enemigos u otras fuentes
#--------------------------------------------------------------------------------
func recibir_dmg(danio: float = 1.0) -> void:
	for i in range(int(danio)):
		perder_vida()
