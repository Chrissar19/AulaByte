# ====================================================================
# COMPONENTE: EFECTO DE RECOLECCIÓN
# ====================================================================
## Maneja la animación de "vuelo" y desvanecimiento al recoger un puntos.
extends Node

# ====================================================================
# PARÁMETROS CONFIGURABLES
# ====================================================================
@export var distancia_vuelo: float = 60.0
@export var duracion_efecto: float = 0.75

# ====================================================================
# NODOS
# ====================================================================
@onready var area_moneda: Area2D = $".."
@onready var sprite_animado: AnimatedSprite2D = $"../AnimatedSprite2D"

# ====================================================================
# INICIALIZACIÓN Y CONFIGURACIÓN
# ====================================================================
func _ready() -> void:
	# Conecta a la senial del padre para activar el efecto
	if area_moneda.has_signal("reproducir_animacion_destruccion"):
		area_moneda.reproducir_animacion_destruccion.connect(_on_reproducir_animacion_destruccion)
	
	# Desactiva la autodestrucción inmediata del padre para ver la animación
	area_moneda.autodestruir = false

# ====================================================================
# MANEJO DE SEÑALES Y ANIMACIÓN
# ====================================================================

func _on_reproducir_animacion_destruccion() -> void:
	_ejecutar_animacion_recoleccion()

func _ejecutar_animacion_recoleccion() -> void:
	# Configura el Tween para que los efectos ocurran en paralelo
	var tween_efecto := get_tree().create_tween().bind_node(area_moneda).set_parallel(true)
	
	# Efecto de movimiento ascendente (Vector2.UP)
	tween_efecto.tween_property(
		area_moneda, 
		"position", 
		area_moneda.position + Vector2.UP * distancia_vuelo, 
		duracion_efecto
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# Efecto de desvanecimiento (Alpha)
	tween_efecto.tween_property(
		sprite_animado, 
		"self_modulate:a", 
		0.0, 
		duracion_efecto
	)
	
	# Espera a que la animación termine antes de liberar el objeto en memoria
	await tween_efecto.finished
	area_moneda.queue_free()
