extends Node

#export permite modificar las variables desde el editor 2D
@onready var bits_moneda: Area2D = $".."
@export var distancia_moneda: float = 60
@export var duracion_moneda: float = 0.75
@onready var animated_sprite: AnimatedSprite2D = $"../AnimatedSprite2D"
 
func _ready() -> void:
	# Llama al metodo cuando el objeto toca la moneda
	bits_moneda.reproducir_animacion_destruccion.connect(_on_reproducir_animacion_destruccion)
	bits_moneda.autodestruir = false

func _on_reproducir_animacion_destruccion() -> void:
	# Tween son como animaciones y efectos
	var tween = get_tree().create_tween().bind_node(bits_moneda).set_parallel(true) # Asocia ala variable tween a la moneda
	tween.tween_property(bits_moneda, "position", bits_moneda.position + Vector2.UP * distancia_moneda, duracion_moneda).set_trans(tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(animated_sprite, "self_modulate", Color(Color.WHITE, 0),duracion_moneda)
	await tween.finished
	bits_moneda.queue_free()
