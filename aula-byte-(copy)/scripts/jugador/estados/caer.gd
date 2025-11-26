extends EstadoBase
class_name EstadoCaer

func enter(jugador: Node) -> void:
    estado = jugador

func actualizar_fisicas(delta: float) -> void:
    var dir = estado.input_dir
    estado.velocity.x = lerp(estado.velocity.x, dir * estado.VEL_HORIZONTAL, 0.08)
    if estado.is_on_floor():
        if abs(estado.velocity.x) > 0.1:
            estado.cambiar_estado("caminar")
        else:
            estado.cambiar_estado("idle")
