# ====================================================================
# OBJETO AMBIENTAL: NUBE
# ====================================================================
## Controla el comportamiento visual de las nubes, su movimiento y desvanecimiento.
extends Node2D
class_name Nube

# ====================================================================
# PARÁMETROS CONFIGURABLES
# ====================================================================
@export var velocidad: float = 30.0          # Velocidad de desplazamiento horizontal
@export var distancia_inicio_fade: float = 80.0  # px ANTES del borde donde empieza a desvanecerse
@export var margen_fuera_pantalla: float = 50.0

# ============================================================================
# NODOS
# ============================================================================
@onready var sprite_nube: Sprite2D = $Sprite2D

# ============================================================================
# VARIABLES INTERNAS
# ============================================================================
var alpha_max: float = 1.0              # Transparencia máxima (0.0 - 1.0)
var desvanecer_iniciado: bool = false   # Evita múltiples tween de salida

# ====================================================================
# INICIALIZACIÓN Y LÓGICA DE PROCESO
# ====================================================================
func _ready() -> void:
	# Configuración de los frames del sprite (6 horizontales)
	sprite_nube.hframes = 6
	sprite_nube.vframes = 1
	sprite_nube.frame = randi() % sprite_nube.hframes
	# Selección de opacidad aleatoria
	alpha_max = randf_range(0.3, 1.0)
	sprite_nube.modulate.a = 0.0
	# Efecto de entrada suavex
	_crear_tween_entrada()

func _process(delta: float) -> void:
	_mover_nube(delta)
	_gestionar_desvanecimiento()

func _mover_nube(delta: float) -> void:
	position.x += velocidad * delta

func _gestionar_desvanecimiento() -> void:
	var ancho_pantalla := get_viewport_rect().size.x
	var inicio_fade := ancho_pantalla - distancia_inicio_fade
	var fin_fade := ancho_pantalla + margen_fuera_pantalla
	# Activar desvanecimiento al acercarse al borde derecho
	if not desvanecer_iniciado and position.x >= inicio_fade:
		_iniciar_fade_salida(fin_fade)

	# Eliminación del nodo al salir completamente de escena
	if position.x >= fin_fade:
		queue_free()

func _iniciar_fade_salida(posicion_final: float) -> void:
	desvanecer_iniciado = true
	
	var distancia_restante: float = max(posicion_final - position.x, 1.0)
	var duracion_fade: float = distancia_restante / max(velocidad, 1.0)
	var tween := create_tween()
	tween.tween_property(sprite_nube, "modulate:a", 0.0, duracion_fade)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)
		
func _crear_tween_entrada() -> void:
	var tween := create_tween()
	tween.tween_property(sprite_nube, "modulate:a", alpha_max, 1.2)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
