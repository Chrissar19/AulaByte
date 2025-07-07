extends PlayerState #--SE CAMBIA SIEMPRE EL extends a PlayerState de todos los estados

#--REEMPLAZO DE LA FUNCION _ready()
func enter():
	player.empuje_ray.enabled = false #--Desactiva el RayCast para detectar coliciones
	print("Estado Idle", " y estado del ray: ", player.empuje_ray.enabled)
	node.velocity.x = 0
	actualizar_animacion(player.animations.delgado_idle_no)
	
func physics_process(_delta):
	
	#--Transicion a movimiento
	if Input.is_action_pressed("derecha") or Input.is_action_pressed("izquierda"):
		#-- NO AGREGAR CODIGO DESPUES DE CAMBIAR DE ESTADO (state_machine.cambiar a) POR QUE NO SE EJECUTARA
		state_machine.cambiar_a(node.states._walk)
		return
	
	if Input.is_action_just_pressed("saltar") and player.coyote_timer > 0:
		#-- NO AGREGAR CODIGO DESPUES DE CAMBIAR DE ESTADO (state_machine.cambiar a) POR QUE NO SE EJECUTARA
		state_machine.cambiar_a(player.states._jump_up)
		return #-- EVITA EJECUTAR EL RESTO DEL CODIGO
		
