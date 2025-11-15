#-- Caminar
extends EstadoBase

class_name EstadoCaminar

func enter(jugador: Node) -> void:
	estado = jugador
	
func actualizar_fisicas(delta: float) -> void:
	var dir = estado.input_dir

	# Usar SIEMPRE la función del jugador (aquí entra el boost de velocidad)
	estado.mov_horizontal(dir)
	
	# --- Cambios de estado ---
	if not estado.is_on_floor():
		estado.cambiar_estado("caer")
		return
		
	if estado.esta_empujando:
		estado.cambiar_estado("empujar")
		return
		
	if dir == 0:
		estado.cambiar_estado("idle")
		return
