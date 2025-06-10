extends Node

var puntuacion = 0
@onready var txt_puntuacion: Label = $txtPuntuacion

signal puntuacion_actualizada(puntuacion_actual: int)

func incrementa_puntos():
	puntuacion += 1
	puntuacion_actualizada.emit(puntuacion)
	txt_puntuacion.text = str(puntuacion) + " Puntos"
