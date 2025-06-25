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

func enter():
	pass
