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
	get:
		return _node_ref

#--MÉTODOS A SOBREESCRIBIR EN LOS ESTADOS--
func enter():
	#-- se ejecuta al entrar al estado
	pass

func physics_process(delta: float) -> void:
	#-- AÑADIR GRAVEDAD--
	if not player.is_on_floor():
		player.velocidad += player.get_gravity() * delta #--Se le suma la velocidad a la gravedad
		
	player.move_and_slide()
	
func actualizar_animacion(nueva_animacion: String):
	player.animation_player.play(nueva_animacion)
