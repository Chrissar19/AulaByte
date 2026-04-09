extends Node2D

# ============================================================================
# VARIABLES
# ============================================================================
@export var fuerza_rebote: float = -700.0  
@onready var saltarin: AudioStreamPlayer = $Saltarin

var jugador: CharacterBody2D = null
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer

func _ready() -> void:
	if sprite.sprite_frames.has_animation("salto"):
		sprite.animation = "salto"
	sprite.stop()
	if not timer.timeout.is_connected(_on_timer_timeout):
		timer.timeout.connect(_on_timer_timeout)

# ============================================================================
# REBOTE
# ============================================================================
func _on_activacion_salto_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		var p = body 

		if p.velocity.y > 0:
			p.velocity.y = fuerza_rebote
			if p.has_method("cambiar_estado"):
				p.cambiar_estado("saltar")
			
			if "ha_saltado" in p:
				p.ha_saltado = true 
			
			saltarin.play()

			sprite.play("salto")
			timer.start(0.4)
		else:
			# Si el jugador está en el suelo o subiendo, no hace nada
			print("Jugador cruzando sin caer: Trampolín desactivado")

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		jugador = null

func _on_timer_timeout() -> void:
	if sprite.sprite_frames.has_animation("encoger"):
		sprite.play("encoger")
	else:
		sprite.stop()
