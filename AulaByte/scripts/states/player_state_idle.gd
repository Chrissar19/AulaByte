extends PlayerState #--SE CAMBIA SIEMPRE EL extends a PlayerState de todos los estados

#--REEMPLAZO DE LA FUNCION _ready()
func enter():
	player.empuje_ray.enabled = false #--Desactiva el RayCast para detectar coliciones
	print("Estado Idle", " y estado del ray: ", player.empuje_ray.enabled)
	actualizar_animacion(player.animations.jojoa_idle_no)
	
#--Cambiar de estado Idle a estado Move
func process(_delta):
	if Input.is_action_pressed("derecha"):
		#-- NO AGREGAR CODIGO DESPUES DE CAMBIAR DE ESTADO (state_machine.cambiar a) POR QUE NO SE EJECUTARA
		state_machine.cambiar_a(player.states._walk)
	elif  Input.is_action_pressed("izquierda"):
		print("CAMINANDO A IZQUIERDA")
		state_machine.cambiar_a(player.states._walk)
	elif Input.is_action_pressed("saltar"):
		print("Saltar desde Idle")
		state_machine.cambiar_a(player.states._jump)
