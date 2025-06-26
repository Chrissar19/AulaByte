extends CharacterBody2D
class_name Player

#--AGREGAR LAS VARIABLES A ESTE NODO PARA QUE SEAN VARIABLES GLOBALES EN LA MAQUINA DE ESTADOS
@onready var state_machine: StateMachine = $StateMachine
var states: PlayerStates = PlayerStates.new()
@onready var animation_player: AnimatedSprite2D = $AnimatedSprite2D
var animations: PlayerAnimations = PlayerAnimations.new()
