extends Area2D

@onready var sound_moneda: AudioStreamPlayer2D = $SoundMoneda
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

@export var valor: int = 1 #-- valor que otorga la moneda
var autodestruir : bool = true
signal reproducir_animacion_destruccion

func _on_body_entered(_body: Node2D) -> void:
	
	JugadorSeleccionado.agregar_puntos(valor) #-- Suma puntos al jugador
	#-- Actualizar el HUD
	var hud = get_tree().get_first_node_in_group("HUD")
	if hud:
		hud.actualizar_puntos(JugadorSeleccionado.get_puntos())
		
	#-- Reproducir sonido y animacion
	sound_moneda.play()
	collision_shape.call_deferred("set", "disabled", true) # Elimina la colision del objeto
	
	if autodestruir:
		animated_sprite.visible = false
		sound_moneda.finished.connect(_on_finished)
	else:
		# Activa la señal moneda "Emitiendo" su señal
		reproducir_animacion_destruccion.emit()
		
func _on_finished() -> void:
	queue_free()
