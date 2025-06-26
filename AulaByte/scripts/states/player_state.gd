extends Node

class_name PlayerState

var state_machine: StateMachine

var node: Player:
	#--Cada vez que se cambie el valor de node, tambien se cambiara player
	set (value):
		node = value
		player = value
	get:
		return node
		
var player: Player

#--ESTA FUNCION SOBREESCRIBE LA FUNCION ready
func enter():
	pass

func actualizar_animacion(nueva_animacion: String):
	player.animation_player.play(nueva_animacion)
