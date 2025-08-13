extends EstadoBase

class_name EstadoIdle

func enter(_estado: Node) -> void:
	estado = _estado
	estado.estado_actual = estado.Estado.IDLE

func actualizar_fisicas(delta: float) -> void:
	var dir = estado.input_dir
	if not estado.is_on_floor():
		estado.cambiar_estado("caer")
		return
	if estado.esta_empujando:
		estado.cambiar_estado("empujar")
		return
	if dir != 0:
		estado.cambiar_estado("caminar")
		return
	estado.velocity.x = lerp(estado.velocity.x, 0.0, 0.25)
