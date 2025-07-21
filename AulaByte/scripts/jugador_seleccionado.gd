extends Node

var id_personaje: int = -1 #--Aun ningun personaje seleccionado
var info_personaje: personajeInfo = null

func seleccionar(id: int) -> void:
	id_personaje = id
	
func set_info(info: personajeInfo) -> void:
	info_personaje = info
	
func get_info() -> personajeInfo:
	return info_personaje 
	
func obtener_id() -> int:
	return id_personaje
