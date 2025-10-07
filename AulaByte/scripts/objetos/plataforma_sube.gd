extends Node2D

@onready var area_2d: Area2D = $Area2D
@onready var timer_subida: Timer = $TimerSubida

@export var auto_play := false
@export var vel_subida := 40.0
@export var distancia_max := -200.0
@export var tiempo_espera := 0.5

var jugador_encima := false
var pos_inicial: Vector2
var desplazamiento := 0.0
var subiendo := false
var bajando := false

func _ready() -> void:
	pos_inicial = global_position
	area_2d.body_entered.connect(_on_area_2d_body_entered)
	area_2d.body_exited.connect(_on_area_2d_body_exited)
	timer_subida.timeout.connect(_on_timer_subida_timeout)
	timer_subida.wait_time = tiempo_espera
	timer_subida.one_shot = true

	if auto_play:
		bajando = true

func _process(delta: float) -> void:
	if auto_play:
		if bajando:
			if desplazamiento > distancia_max:
				global_position.y -= vel_subida * delta
				desplazamiento -= vel_subida * delta
			else:
				bajando = false
				timer_subida.start()
		elif subiendo:
			if desplazamiento < 0:
				global_position.y += vel_subida * delta
				desplazamiento += vel_subida * delta
			else:
				subiendo = false
				desplazamiento = 0.0
				global_position = pos_inicial
				timer_subida.start()
	else:
		if jugador_encima:
			if desplazamiento > distancia_max:
				global_position.y -= vel_subida * delta
				desplazamiento -= vel_subida * delta
		elif subiendo:
			if desplazamiento < 0:
				global_position.y += vel_subida * delta
				desplazamiento += vel_subida * delta
			else:
				subiendo = false
				desplazamiento = 0.0
				global_position = pos_inicial
				timer_subida.stop()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if !auto_play and body.is_in_group("Jugador"):
		jugador_encima = true
		timer_subida.stop()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if !auto_play and body.is_in_group("Jugador"):
		jugador_encima = false
		timer_subida.start()

func _on_timer_subida_timeout() -> void:
	if auto_play:
		if not subiendo and not bajando:
			if desplazamiento <= distancia_max:
				subiendo = true
			else:
				bajando = true
	else:
		subiendo = true
