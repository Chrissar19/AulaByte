extends Node
class_name PlayerState

#--Referencias que inyecta la Statemachine al entrar a un estado
var state_machine: StateMachine

var _node_ref: Player
var player: Player

var node: Player:
	#--Cada vez que se cambie el valor de node, tambien se cambiara player
	set (value):
		_node_ref = value
		player = value
		print("Asignado player desde setter: ", player)
	get:
		return _node_ref

#--MÉTODOS A SOBREESCRIBIR EN LOS ESTADOS--
func enter():
	#-- se ejecuta al entrar al estado
	pass
	
func actualizar_animacion(nueva_animacion: String):
	player.animation_player.play(nueva_animacion)
