#-- Saltar
extends EstadoBase

class_name estadoSaltar

func enter(jugador: Node) -> void:
	estado = jugador
	estado.velocity.y = estado.FUERZA_SALTO
	if estado.sonido_salto:
		estado.sonido_salto.play()
		
func actualizar_fisicas(delta: float) -> void:
	var dir = estado.input_dir
	estado.velocity.x = lerp(estado.velocity.x, dir * estado.VEL_HORIZONTAL, 0.08)
	if estado.velocity.y > 0:
		estado.cambiar_estado("caer")
		return
