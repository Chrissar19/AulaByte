#-- res://scripts/nubes.gd
extends Node2D
class_name Nube

# ============================================================================
# EXPORTS
# ============================================================================
@export var velocidad: float = 30.0  # Velocidad de desplazamiento horizontal

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

    # Iniciar desvanecido cuando se acerque al borde derecho
    if not desvanecer_iniciado and position.x > ancho_vp - 120:
        desvanecer_iniciado = true

        create_tween()\
            .tween_property(sprite_nube, "modulate:a", 0.0, 1.0)\
            .set_trans(Tween.TRANS_SINE)\
            .set_ease(Tween.EASE_IN)\
            .finished.connect(func(): queue_free())

    # Eliminación por seguridad si pasa el borde
    if position.x > ancho_vp + 100:
        queue_free()
