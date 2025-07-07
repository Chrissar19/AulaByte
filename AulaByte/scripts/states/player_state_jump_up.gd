extends PlayerState

func enter():
	#--Inicia el salto y animacion de subida
	player.sound_jump.play()
	actualizar_animacion(player.animations.delgado_up_no)
	node.velocity.y = node.FUERZA_SALTO
	
func physics_process(_delta):
	#--Permite moverse en el aire
	var dir := player.movimiento_y_direccion()
	
	#--Si esta cayendo, cambia estado a jumpDown
	if  node.velocity.y > 0:
		state_machine.cambiar_a(player.states._jump_down)
		return
	elif node.velocity.y == 0:
		state_machine.cambiar_a(player.states._idle)
		return
