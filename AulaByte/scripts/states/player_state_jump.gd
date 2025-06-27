extends PlayerState #--SE CAMBIA SIEMPRE EL extends a PlayerState de todos los estados

# Called when the node enters the scene tree for the first time.
func enter():
	player.empuje_ray.enabled = true #--Activa el RayCast para detectar coliciones
	player.empuje_ray.target_position = Vector2.ZERO #--reposiciona el rayCast
	print("Estado Salto ", "y estado del ray: ", player.empuje_ray.enabled)
	actualizar_animacion(player.animations.jojoa_up_no)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func process(_delta):
	if Input.is_action_pressed("izquierda"):
		print("Camino a la izquierda")
#-- NO AGREGAR CODIGO DESPUES DE CAMBIAR DE ESTADO (state_machine.cambiar a) POR QUE NO SE EJECUTARA
		state_machine.cambiar_a(player.states._walk)
	elif Input.is_action_pressed("derecha"):
		print("CAMINO DERECHA")
		state_machine.cambiar_a(player.states._walk)
	elif Input.is_action_pressed("ui_down"):
		print("Idle desde Jump")
		state_machine.cambiar_a(player.states._idle)
