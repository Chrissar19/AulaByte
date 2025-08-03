extends Node2D

# =============================================================================
# TRAMPOLÍN - Rebota al jugador cuando cae sobre él
# =============================================================================

# ============================================================================
# VARIABLES
# ============================================================================
@export var fuerza_rebote: float = -400.0        # Fuerza de impulso vertical

var jugador: CharacterBody2D = null              # Referencia al jugador
var verificar_salto: bool = false                # Estado de rebote activo

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer

# ============================================================================
# READY - Inicializa animación y conecta señales
# ============================================================================
func _ready() -> void:
	sprite.animation = "salto"
	sprite.stop()
	timer.timeout.connect(_on_timer_timeout)

# ============================================================================
# REBOTE - Al entrar el jugador en contacto
# ============================================================================
func _on_activacion_salto_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador") and not body.is_on_floor():
		jugador = body
		verificar_salto = true
		
		# Rebote solo si el jugador está cayendo
		if jugador.velocity.y >= 0:
			jugador.velocity.y = fuerza_rebote
			sprite.play("salto")
			timer.start(1.5)

# ============================================================================
# SALIDA - Se detiene el rebote al salir del trampolín
# ============================================================================
func _on_body_exited(body: Node2D) -> void:
	if body == jugador:
		jugador = null
		verificar_salto = false

# ============================================================================
# TIMER - Después de 1.5 seg cambia la animación
# ============================================================================
func _on_timer_timeout() -> void:
	sprite.play("encoger")
