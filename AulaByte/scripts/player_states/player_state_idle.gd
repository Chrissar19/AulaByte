extends PlayerState #--SE CAMBIA SIEMPRE EL extends a PlayerState de todos los estados

func enter():
	print("Estado Idle")

#--Cambiar de estado Idle a estado Move
func process(_delta):
	if Input.is_action_pressed("derecha"):
		state_machine.cambiar_a("PlayerStateMove")
