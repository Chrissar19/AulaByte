extends Area2D

@onready var animacion_puerta: AnimatedSprite2D = $AnimacionPuerta

var jugador_en_rango := false
var puerta_abierta := false

func _ready() -> void:
	animacion_puerta.stop()
	animacion_puerta.frame = 0
	
func _process(delta: float) -> void:
	if jugador_en_rango and Input.is_action_just_pressed("Accion") and not puerta_abierta:
		abrir_puerta()
		
func abrir_puerta():
	puerta_abierta = true
	animacion_puerta.play("Abriendo")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador") and not puerta_abierta:
		jugador_en_rango = true
	
func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		jugador_en_rango = false
