extends Node

var id_personaje: int = -1 #--Aun ningun personaje seleccionado
var info_personaje: personajeInfo = null
var tiempo_nivel_actual: float = 0.0

func seleccionar(id: int) -> void:
	id_personaje = id
	
func set_info(info: personajeInfo) -> void:
	info_personaje = info
	
func get_info() -> personajeInfo:
	return info_personaje 
	
func obtener_id() -> int:
	return id_personaje

func set_tiempo(tiempo: float) -> void:
	tiempo_nivel_actual = tiempo

func get_tiempo() -> float:
	return tiempo_nivel_actual
