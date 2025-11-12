extends Area2D

# ============================================================================
# EXPORTS
# ============================================================================
@export var valor: int = 1       # Valor en puntos que otorga la moneda
@export var animacion: bool = true    # Si es verdadera, la moneda se destruye tras recolectarla
@export var distancia_moneda: float = 60 #-- Distancia que recorerra al desaparecer
@export var duracion_moneda: float = 0.75

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

	#-- Desactivar colisioes
	colision.call_deferred("set", "disabled", true)
	
	# Reproducir sonido
	sonido_moneda.play()
	
	#-- Efectos visuales
	if animacion:
		_animacion_destruccion()
	else:
		sprite.visible = false
		sonido_moneda.finished.connect(_on_sonido_terminado)
		
func _animacion_destruccion() -> void:
	var tween = get_tree().create_tween().bind_node(self).set_parallel(true)
	tween.tween_property(self, "position", position + Vector2.UP * distancia_moneda, duracion_moneda).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "self_modulate", Color(Color.WHITE, 0), duracion_moneda)
	await tween.finished
	queue_free()

func _on_sonido_terminado() -> void:
	queue_free()
