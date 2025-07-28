extends Node

signal vida_ganada
signal vida_perdida

var id_personaje: int = -1 #--Aun ningún personaje seleccionado
var info_personaje: personajeInfo = null
var vidas: int = 3
const VIDAS_MAX := 5
var puntos: int = 0
var tiempo_nivel_actual: float = 0.0

func seleccionar(id: int) -> void:
	id_personaje = id
	
func set_info(info: personajeInfo) -> void:
	info_personaje = info
	
func get_info() -> personajeInfo:
	return info_personaje 
	
func obtener_id() -> int:
	return id_personaje

#---------------------------------------------------------------------------------------------------
#-- TIEMPO EN EL NIVEL
#---------------------------------------------------------------------------------------------------
func set_tiempo(tiempo: float) -> void:
	tiempo_nivel_actual = tiempo

func get_tiempo() -> float:
	return tiempo_nivel_actual
	
#---------------------------------------------------------------------------------------------------
#-- Puntos
#---------------------------------------------------------------------------------------------------
func agregar_puntos(cantidad: int) -> void:
	puntos += cantidad

func reiniciar_puntos() -> void:
	puntos = 0
	
func get_puntos() -> int:
	return puntos
#---------------------------------------------------------------------------------------------------
#-- MANEJO DE VIDAS
#---------------------------------------------------------------------------------------------------
func perder_vida() -> void:
	if vidas > 0:
		vidas -= 1
		emit_signal("vida_perdida")
		vidas = max(vidas, 0)
		if vidas == 0:
			morir()

func ganar_vida() -> void:
	if vidas < VIDAS_MAX:
		vidas += 1
		emit_signal("vida_ganada")

func reiniciar_vidas() -> void:
	vidas = 3
	
func get_vidas() -> int:
	return vidas
	
func morir():
	get_tree().change_scene_to_file("res://escenas/menu/menu_perder.tscn")
