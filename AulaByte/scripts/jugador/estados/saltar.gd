#-- Saltar
extends EstadoBase

class_name estadoSaltar

func enter(jugador: Node) -> void:
	estado = jugador
	estado.salto()
		
func actualizar_fisicas(delta: float) -> void:
	var dir = estado.input_dir
	estado.mov_horizontal(dir)
	
	if estado.velocity.y > 0.0:
		estado.cambiar_estado("caer")
		return
