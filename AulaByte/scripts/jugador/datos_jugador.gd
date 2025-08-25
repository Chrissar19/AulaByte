extends Node

class_name JugadorDatos

signal vida_modificada(nueva_vida)
signal puntos_modificados(nuevos_puntos)

var vidas: int = 3
var puntos: int = 0

func perder_vida():
	vidas = max(vidas - 1, 0)
	emit_signal("vida_modificada", vidas)
	
func ganar_puntos(cantidad: int):
	puntos += cantidad
	emit_signal("puntos_modificados", puntos)
