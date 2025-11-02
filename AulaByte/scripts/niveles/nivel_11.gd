extends NivelBase

@onready var pared: Pared = $Plataformas/Pared

func _ready() -> void:
	call_deferred("_connect_game_manager_signals")
	super._ready()

func _on_jefe_final_ondead() -> void:
	pared.destroy()

func _on_jaula_cuy_on_cuy_liberado() -> void:
	if Engine.has_singleton("GameManager") or (typeof(GameManager) != TYPE_NIL and GameManager):
		if GameManager.estado_actual == GameManager.EstadoJuego.JUGANDO:
			GameManager.terminar_juego()
