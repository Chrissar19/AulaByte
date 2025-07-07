extends PlayerState

#--Estado de empujar caja
@export var push_force: float = 1000.0 #--Fuerza que aplica el jugador al empujar

#--REEMPLAZO DE LA FUNCION _ready()
func enter():
	player.empuje_ray.enabled = true
	player.velocity.x = 0
	actualizar_animacion(player.animations.delgado_push_no)
	print("ESTADO PUSH")
	
func physics_process(_delta):
	var dir := player.movimiento_y_direccion()
	
	#--Verificar colision con caja
	if player.empuje_ray.is_colliding():
		var caja := player.empuje_ray.get_collider()
		if caja.is_in_group("Cajas"):
			#--Salto desde el estado empuje
			if Input.is_action_just_pressed("saltar") and player.coyote_timer > 0:
				state_machine.cambiar_a(player.states._jump_up)
				return
			
			#--Si el jugador se mueve, empuja la caja
			if dir != 0:
				#--Aplicar fuerza a la caja
				caja.recibir_empuje(Vector2(dir * push_force, 0))
				#--Reducir velocidad del jugador al empujar
				player.velocity.x = dir * player.VEL_HORIZONTAL * 0.5
				actualizar_animacion(player.animations.delgado_push_no)
			else:
				player.velocity.x = 0
				actualizar_animacion(player.animations.delgado_push_no)
			
			#--Mover al jugador
			player.move_and_slide()
			return
	
	#--Si ya no colisiona, volver a walk
	state_machine.cambiar_a(player.states._walk)
	
