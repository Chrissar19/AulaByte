extends Area2D

@export var fuerza_rebote := -400.0

var jugador: CharacterBody2D = null
var verificar_salto := false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer

func _ready() -> void:
	sprite.stop()
	sprite.animation = "salto"
	sprite.frame = 0
	body_entered.connect(_on_body_entered)
	body_entered.connect(_on_body_exited)

func _on_body_entered(body) -> void:
	if body.is_in_group("Jugador") and not body.is_on_floor():
		jugador = body
		verificar_salto = true
		sprite.play("salto")
		timer.start(2.0)
		
		#-- Rebote automatico
		if jugador.velocity.y >= 0:
			jugador.velocity.y = fuerza_rebote

func _on_body_exited(body):
	if body == jugador:
		jugador = null
		verificar_salto = false
		
func _on_timer_timeout():
	sprite.play("encoger")
