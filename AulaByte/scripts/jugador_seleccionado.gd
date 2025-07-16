extends Node

var id_personaje: int = -1 #--Aun ningun personaje seleccionado

func seleccionar(id: int) -> void:
	id_personaje = id
	
func obtener_id() -> int:
	return id_personaje
