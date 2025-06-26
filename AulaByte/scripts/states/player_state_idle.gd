extends PlayerState #--SE CAMBIA SIEMPRE EL extends a PlayerState de todos los estados

func enter():
	print("Estado Idle")
	#player.animation_player.play(player.animations.jojoa_idle_no)
	actualizar_animacion(player.animations.jojoa_idle_no)
#--Cambiar de estado Idle a estado Move
func process(_delta):
	if Input.is_action_pressed("derecha"):
		#-- NO AGREGAR CODIGO DESPUES DE CAMBIAR DE ESTADO (state_machine.cambiar a) POR QUE NO SE EJECUTARA
		state_machine.cambiar_a(player.states._walk)
