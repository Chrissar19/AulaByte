extends EstadoBase

class_name EstadoIdle

func enter(jugador: Node) -> void:
    estado = jugador

func actualizar_fisicas(delta: float) -> void:
    if not estado.is_on_floor():
        estado.cambiar_estado("caer")
        return
    elif estado.esta_empujando:
        estado.cambiar_estado("empujar")
        return
    elif estado.input_dir != 0:
        estado.cambiar_estado("caminar")
    else:
        estado.velocity.x = lerp(estado.velocity.x, 0.0, 0.25)
