extends Node2D

@onready var area_2d: Area2D = $Area2D
@onready var timer_subida: Timer = $TimerSubida

@export var vel_bajada := 30.0 #-- Que tan rapido baja
@export var distancia_max := 200.0 #-- Hata donde baja
@export var tiempo_espera := 0.5 #-- Tiempo en volver a subir

var jugador_encima := false
var pos_inicial: Vector2
var desplazamiento := 0.0
var subiendo := false


func _ready() -> void:
	pos_inicial = global_position
	area_2d.body_entered.connect(_on_area_2d_body_entered)
	area_2d.body_exited.connect(_on_area_2d_body_exited)
	
	
func _process(delta: float) -> void:
	if jugador_encima:
		if desplazamiento < distancia_max:
			global_position.y += vel_bajada * delta
			desplazamiento += vel_bajada * delta
			
	elif subiendo:
		if desplazamiento > 0:
			global_position.y -= vel_bajada * delta
			desplazamiento -= vel_bajada * delta
		else:
			subiendo = false
			desplazamiento = 0.0
			global_position = pos_inicial
			timer_subida.stop()
				

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		print("SUBIDO")
		jugador_encima = true
		timer_subida.stop()


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		print("BAJO")
		jugador_encima = false
		timer_subida.start()


func _on_timer_subida_timeout() -> void:
	print("SUBIENDO")
	subiendo = true
