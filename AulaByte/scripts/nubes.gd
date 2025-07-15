extends Node2D

@export var velocidad := 30.0
@onready var sprite_nubes: Sprite2D = $Sprite2D #-- Enlace al sprite
var alpha_max: float #-- Transparencia (0-1)
var desvanecer_iniciado := false

func _ready() -> void:
	#-- Elegir 1 de los 6 frames aleatoriamente
	sprite_nubes.hframes = 6
	sprite_nubes.vframes = 1
	sprite_nubes.frame = randi() % sprite_nubes.hframes
	
	#-- Trasnparencia aleatoria --
	alpha_max = randf_range(0.3, 1.0)
	sprite_nubes.modulate.a = 0.0  #-- Empieza invicible
	
	#-- desvanecido siave --
	create_tween()\
	.tween_property(sprite_nubes, "modulate:a", alpha_max, 1.2)\
	.set_trans(Tween.TRANS_SINE)\
	.set_ease(Tween.EASE_OUT)
	
func _process(delta: float) -> void:
	#-- Movimiento horizontal ---
	position.x += velocidad * delta
	
	#-- Iniciar el desvanecido cuando la nuve se acerca al borde derecho
	var vp_w := get_viewport_rect().size.x
	if not desvanecer_iniciado and position.x > vp_w - 120:
		desvanecer_iniciado = true
		create_tween()\
		.tween_property(sprite_nubes, "modulate:a", 0.0, 1.0)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)\
		.finished.connect(func(): queue_free())
	
	#-- Por seguridad, si falla algun tween
	if position.x > get_viewport_rect().size.x + 100:
		queue_free()
