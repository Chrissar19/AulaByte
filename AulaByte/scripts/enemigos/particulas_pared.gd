extends CPUParticles2D

# ============================================================================
# CONFIGURACIÓN DE EFECTO
# ============================================================================
@export var velocidad_animacion: float = 0.8
@export var variacion_rotacion: float = 0.8
@export var frecuencia_oscilacion: float = 2.0
@export var intensidad_oscilacion: float = 10.0

# ============================================================================
# VARIABLES INTERNAS
# ============================================================================
var _tiempo: float = 0.0

# ============================================================================
# READY
# ============================================================================
func _ready() -> void:
	emitting = false
	
	spread = 60
	lifetime *= 1.6
	randomness = 0.05
	gravity = Vector2(0, 300)
	speed_scale = velocidad_animacion
	
	set_process(true)

# ============================================================================
# PROCESO
# ============================================================================
func _process(delta: float) -> void:
	if not emitting:
		return
		
	_tiempo += delta
	gravity.x = sin(_tiempo * frecuencia_oscilacion * 0.5) * intensidad_oscilacion * 2.0
	gravity.y = 300 + cos(_tiempo * frecuencia_oscilacion * 0.3) * 20.0
