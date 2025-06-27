extends PlayerState #--SE CAMBIA SIEMPRE EL extends a PlayerState DE TODOS LOS ESTADOS

#--REEMPLAZO DE LA FUNCION _ready()
func enter():
	player.empuje_ray.enabled = true #--Activa el RayCast para detectar coliciones
	player.empuje_ray.target_position = Vector2.ZERO #--reposiciona el rayCast
	print("Estado Walk ", "y estado del ray: ", player.empuje_ray.enabled)
	actualizar_animacion(player.animations.jojoa_walk_no)
	
func physics_process(_delta):
	#--Guardar el estado anterior de empuje
	player.estaba_empujando = player.esta_empujando
	#--reinicia estado de empuje
	player.esta_empujando = false
	
#--Cambiar de estado Move a estado Idle
func process(_delta):
	if Input.is_action_pressed("ui_down"):
#-- NO AGREGAR CODIGO DESPUES DE CAMBIAR DE ESTADO (state_machine.cambiar a) POR QUE NO SE EJECUTARA
		state_machine.cambiar_a(player.states._idle)
	elif Input.is_action_pressed("saltar") and player.is_on_floor():
		player.velocity.y = -player.FUERZA_SALTO
		print("PRESIONO SALTO desde walk")
		state_machine.cambiar_a(player.states._jump)
