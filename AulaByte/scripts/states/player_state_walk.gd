extends PlayerState #--SE CAMBIA SIEMPRE EL extends a PlayerState DE TODOS LOS ESTADOS

#--VARIABLES
var duracion_coyote_time = 0.20
var en_coyote_time: bool = false #--Se activa mientras se pueda dar el coyote time

#--REEMPLAZO DE LA FUNCION _ready()
func enter():
	player.empuje_ray.enabled = true #--Activa el RayCast para detectar coliciones
	player.empuje_ray.target_position = Vector2.ZERO #--reposiciona el rayCast
	print("Estado Walk ", "y estado del ray: ", player.empuje_ray.enabled)
	actualizar_animacion(player.animations.delgado_walk_no)
	
func physics_process(_delta):
	#--Guardar el estado anterior de empuje
	player.estaba_empujando = player.esta_empujando
	#--reinicia estado de empuje
	player.esta_empujando = false
	player.empuje_ray.target_position = Vector2.ZERO

	#--verificar si empuja algo
	if player.empuje_ray.is_colliding() and player.empuje_ray.get_collider().is_in_group("Cajas"):
		state_machine.cambiar_a(player.states._push)
		return
		
	#--Aplica movimiento en el aire
	var dir := player.movimiento_y_direccion()
	
	#--Saltar si esta en el suelo
	if Input.is_action_just_pressed("saltar") and player.coyote_timer > 0:
		state_machine.cambiar_a(player.states._jump_up)
		return #-- EVITA EJECUTAR EL RESTO DEL CODIGO
	elif node.velocity.y > 0:
		state_machine.cambiar_a(player.states._jump_down)
		return #-- EVITA EJECUTAR EL RESTO DEL CODIGO
	
	#-- Transicion a Idle
	if dir == 0:
		state_machine.cambiar_a(node.states._idle)
