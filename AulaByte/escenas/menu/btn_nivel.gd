extends Button

@export var numero_nivel: int = 0

func _ready() -> void:
	actualizar_estado()

func actualizar_estado() -> void:
	var desbloqueado = numero_nivel <= GameManager.nivel_max_desbloqueado
	
	disabled = !desbloqueado
	
	if not desbloqueado:
		modulate = Color(0.3, 0.3, 0.3, 1)
	else:
		modulate = Color(1, 1, 1, 0)
		
func _on_pressed() -> void:
	GameManager.nivel_actual = numero_nivel
	GameManager.cambiar_estado(GameManager.EstadoJuego.CARGANDO)
