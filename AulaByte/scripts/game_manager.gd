extends Node

var puntuacion = 0
@onready var txt_puntuacion: Label = $txtPuntuacion

func incrementa_puntos():
	puntuacion += 1
	txt_puntuacion.text = str(puntuacion) + " Puntos"
