extends PlayerState

func enter():
	#--Animacion de caida
	actualizar_animacion(player.animations.delgado_down_no)
	
func physics_process(_delta):
	#--Permite mover en el aire
	var dir := player.movimiento_y_direccion()
	
	#--Aplicar coyote time
	if Input.is_action_just_pressed("saltar") and player.coyote_timer > 0:
		state_machine.cambiar_a(player.states._jump_up)
		return
		
	#--Al tocar el suelo cambia al estado Idle o Walk
	if node.is_on_floor():
		if dir != 0:
			state_machine.cambiar_a(player.states._walk)
		else:
			node.velocity.x = 0
			state_machine.cambiar_a(player.states._idle)
