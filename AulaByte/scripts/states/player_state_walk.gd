extends PlayerState #--SE CAMBIA SIEMPRE EL extends a PlayerState DE TODOS LOS ESTADOS

func enter():
	print("Este es el estado Move")
	
#--Cambiar de estado Move a estado Idle
func process(_delta):
	if Input.is_action_pressed("izquierda"):
#-- NO AGREGAR CODIGO DESPUES DE CAMBIAR DE ESTADO (state_machine.cambiar a) POR QUE NO SE EJECUTARA
		state_machine.cambiar_a(player.states._idle)
