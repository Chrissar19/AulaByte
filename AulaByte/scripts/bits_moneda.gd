extends Area2D

# ============================================================================
# EXPORTS
# ============================================================================
@export var valor: int = 1       # Valor en puntos que otorga la moneda
var autodestruir: bool = true    # Si es verdadera, la moneda se destruye tras recolectarla

# ============================================================================
# SEÑALES
# ============================================================================
signal reproducir_animacion_destruccion

# ============================================================================
# NODOS
# ============================================================================
@onready var sonido_moneda: AudioStreamPlayer2D = $SoundMoneda
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var colision: CollisionShape2D = $CollisionShape2D

# ============================================================================
# FUNCIONES
# ============================================================================
func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Jugador"):
		return

	# Sumar puntos al jugador
	GameManager.agregar_puntos(valor)

	# Actualizar el HUD si existe
	var hud := get_tree().get_first_node_in_group("HUD")
	if hud:
		hud.actualizar_puntos(GameManager.get_puntos())

	# Reproducir sonido y desactivar colisión
	sonido_moneda.play()
	colision.call_deferred("set", "disabled", true)

	if autodestruir:
		sprite.visible = false
		# Conectar para eliminar después del sonido
		sonido_moneda.finished.connect(_on_sonido_terminado)
	else:
		# Emitir señal para animación personalizada
		reproducir_animacion_destruccion.emit()

func _on_sonido_terminado() -> void:
	queue_free()
