extends EstadoBase
class_name EstadoEmpujar

func enter(_estado: Node) -> void:
	estado = _estado

func actualizar_fisicas(delta: float) -> void:
	var dir = estado.input_dir
	var velocidad_base: float = estado.VEL_HORIZONTAL * 0.5
	estado.velocity.x = dir * velocidad_base if dir != 0 else move_toward(estado.velocity.x, 0, estado.VEL_HORIZONTAL)

	if not estado.esta_empujando:
		if dir == 0:
			estado.cambiar_estado("idle")
		else:
			estado.cambiar_estado("caminar")
		return
