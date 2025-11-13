extends Node2D
class_name Nube

# ============================================================================
# EXPORTS
# ============================================================================
@export var velocidad: float = 30.0          # Velocidad de desplazamiento horizontal
@export var distancia_inicio_fade: float = 80.0  # px ANTES del borde donde empieza a desvanecerse
@export var margen_fuera_pantalla: float = 50.0  # px DESPUÉS del borde donde ya debería haberse ido

# ============================================================================
# NODOS
# ============================================================================
@onready var sprite_nube: Sprite2D = $Sprite2D

# ============================================================================
# VARIABLES INTERNAS
# ============================================================================
var alpha_max: float = 1.0              # Transparencia máxima (0.0 - 1.0)
var desvanecer_iniciado: bool = false   # Evita múltiples tween de salida

# ============================================================================
# FUNCIONES
# ============================================================================
func _ready() -> void:
	# Configurar sprite: 6 frames horizontales, 1 vertical
	sprite_nube.hframes = 6
	sprite_nube.vframes = 1
	sprite_nube.frame = randi() % sprite_nube.hframes

	# Elegir opacidad aleatoria inicial
	alpha_max = randf_range(0.3, 1.0)
	sprite_nube.modulate.a = 0.0

	# Tween de entrada (desvanecer suavemente hasta alpha_max)
	create_tween()\
		.tween_property(sprite_nube, "modulate:a", alpha_max, 1.2)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

func _process(delta: float) -> void:
	# Movimiento horizontal hacia la derecha
	position.x += velocidad * delta

	var ancho_vp := get_viewport_rect().size.x
	var inicio_fade := ancho_vp - distancia_inicio_fade
	var fin_fade := ancho_vp + margen_fuera_pantalla

	# Iniciar desvanecido cuando se acerque al borde derecho
	if not desvanecer_iniciado and position.x >= inicio_fade:
		desvanecer_iniciado = true

		# Calculamos cuánto tiempo debe durar el fade
		var distancia_restante: float = max(fin_fade - position.x, 1.0)
		var duracion_fade: float = distancia_restante / max(velocidad, 1.0)

		create_tween()\
			.tween_property(sprite_nube, "modulate:a", 0.0, duracion_fade)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN)

	# Cuando ya pasó el margen fuera de la pantalla, se elimina
	if position.x >= fin_fade:
		queue_free()
