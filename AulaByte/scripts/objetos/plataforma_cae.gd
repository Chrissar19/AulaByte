extends AnimatableBody2D
class_name PlataformaCae

@onready var area_2d: Area2D = $Area2D
@onready var timer_subida: Timer = $TimerSubida

@export var vel_bajada := 30.0 
@export var distancia_max := 200.0 
@export var tiempo_espera := 0.5 

var jugador_encima := false
var pos_inicial: Vector2
var desplazamiento := 0.0
var subiendo := false

func _ready() -> void:
	z_index = ZCapas.PLATAFORMAS
	add_to_group("Z_PLATAFORMAS")
	pos_inicial = global_position
	
	sync_to_physics = true
	
	area_2d.body_entered.connect(_on_area_2d_body_entered)
	area_2d.body_exited.connect(_on_area_2d_body_exited)
	
	if not timer_subida.timeout.is_connected(_on_timer_subida_timeout):
		timer_subida.timeout.connect(_on_timer_subida_timeout)
	
	timer_subida.wait_time = tiempo_espera
	timer_subida.one_shot = true

func _physics_process(delta: float) -> void:
	var movimiento = Vector2.ZERO

	if jugador_encima:
		if desplazamiento < distancia_max:
			var avance = vel_bajada * delta
			movimiento.y = avance
			desplazamiento += avance
			
	elif subiendo:
		if desplazamiento > 0:
			var avance = vel_bajada * delta
			movimiento.y = -avance
			desplazamiento -= avance
		else:
			subiendo = false
			desplazamiento = 0.0
			global_position = pos_inicial
			timer_subida.stop()
	
	global_position += movimiento

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		jugador_encima = true
		subiendo = false
		timer_subida.stop()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		jugador_encima = false
		timer_subida.start()

func _on_timer_subida_timeout() -> void:
	subiendo = true
