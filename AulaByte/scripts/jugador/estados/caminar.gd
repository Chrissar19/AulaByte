extends EstadoBase

class_name EstadoCaminar

func enter(jugador: Node) -> void:
	estado = jugador
	
func actualizar_fisicas(delta: float) -> void:
	var dir = estado.input_dir
	var vel_base: float = estado.VEL_HORIZONTAL * (0.4 if estado.esta_empujando else 1)
	if dir != 0:
		estado.velocity.x = dir * vel_base
	else:
		estado.velocity.x = move_toward(estado.velocity.x, 0.0, estado.VEL_HORIZONTAL * delta)
	
	if not estado.is_on_floor():
		estado.cambiar_estado("caer")
		return
		
	if estado.esta_empujando:
		estado.cambiar_estado("empujar")
		return
		
	if dir == 0:
		estado.cambiar_estado("idle")
		return
