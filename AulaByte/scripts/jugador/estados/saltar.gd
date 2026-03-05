#-- Saltar (res://scripts/jugador/estados/saltar.gd)
extends EstadoBase

class_name estadoSaltar

func enter(jugador: Node) -> void:
	estado = jugador
	
	if estado.velocity.y >= 0:
		estado.salto()
	else:
		pass
		
func actualizar_fisicas(delta: float) -> void:
	var dir = estado.input_dir
	estado.mov_horizontal(dir)
	
	# Transición a caer cuando la velocidad vertical sea positiva (hacia abajo)
	if estado.velocity.y > 0.0:
		estado.cambiar_estado("caer")
		return
