extends CharacterBody2D
class_name MonitorKernel

# ============================================================================
# EXPORTS Y CONSTANTES
# ============================================================================
@export var monedas: int = 3
@export var velocidad_patrulla: float = 30.0
@export var velocidad_persecucion: float = 60.0
@export var gravedad: float = 400.0
@export var impulso_salto: float = -700.0
@export var distancia_deteccion_borde: float = 32.0
@export var proyectil_escena: PackedScene = preload("res://escenas/personajes/enemigos/proyectil.tscn")
@onready var area_vision: Area2D = $AreaVision

enum Estado { PATRULLAR, PERSEGUIR }
var estado_actual = Estado.PATRULLAR
var jugador_objetivo: Node2D = null

# ============================================================================
# VARIABLES Y NODOS
# ============================================================================
var vida: int = 3
var direccion: int = 1
var base_vida: int = vida

@onready var ray_pared: RayCast2D = $RayPared
@onready var ray_suelo: RayCast2D = $RaySuelo
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var timer_muerte: Timer = $TimerMuerte
@onready var timer_recuperacion: Timer = $TimerRecuperacion
@onready var timer_ataque: Timer = $TimerAtaque
@onready var marker_disparo: Marker2D = $PuntoDisparo
@onready var particulas_monitor: CPUParticles2D = $ParticulasMonitor
@onready var audio_muerte: AudioStreamPlayer2D = $SensorPisoton/AudioMuerte
@onready var collision_monitor: CollisionShape2D = $CollisionMonitor

# ============================================================================
# PROCESO PRINCIPAL
# ============================================================================

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravedad * delta
	
	match estado_actual:
		Estado.PATRULLAR:
			_logica_patrulla()
		Estado.PERSEGUIR:
			_logica_persecucion()

	move_and_slide()
	_actualizar_animaciones()

func _actualizar_animaciones() -> void:
	if sprite.animation == "anim_dead": 
		return
	
	if sprite.animation == "anim_laser" and sprite.is_playing():
		return

	if velocity.x != 0:
		if sprite.animation != "anim_walk":
			sprite.play("anim_walk")
	else:
		if sprite.sprite_frames.has_animation("anim_idle"):
			sprite.play("anim_idle")
		else:
			sprite.stop()

# ============================================================================
# LÓGICA DE MOVIMIENTO
# ============================================================================

func _logica_patrulla() -> void:
	velocity.x = direccion * velocidad_patrulla
	if ray_pared.is_colliding() or (is_on_floor() and not ray_suelo.is_colliding()):
		_girar()

func _logica_persecucion() -> void:
	if jugador_objetivo:
		var dir_hacia_jugador = sign(jugador_objetivo.global_position.x - global_position.x)
		
		if dir_hacia_jugador != direccion:
			_girar()
			
		velocity.x = direccion * velocidad_persecucion
		
		if not ray_suelo.is_colliding() and is_on_floor():
			velocity.x = 0 

func _girar() -> void:
	direccion *= -1
	sprite.flip_h = direccion < 0
	
	# Girar los RayCasts (esto ya lo tenías)
	ray_pared.target_position.x = abs(ray_pared.target_position.x) * direccion
	if ray_suelo:
		ray_suelo.target_position.x = distancia_deteccion_borde * direccion
	
	area_vision.scale.x = direccion
	
	marker_disparo.position.x = abs(marker_disparo.position.x) * direccion
# ============================================================================
# COMBATE Y DETECCIÓN
# ============================================================================

func _on_area_vision_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		jugador_objetivo = body
		estado_actual = Estado.PERSEGUIR
		timer_ataque.start(randf_range(3.0, 4.0))

func _on_area_vision_body_exited(body: Node2D) -> void:
	if body == jugador_objetivo:

		jugador_objetivo = null
		estado_actual = Estado.PATRULLAR
		timer_ataque.stop()

func _on_timer_ataque_timeout() -> void:
	# Solo dispara si el objetivo sigue dentro y el estado es PERSEGUIR
	if jugador_objetivo and estado_actual == Estado.PERSEGUIR:
		_disparar_error()
		# Reinicia el cronómetro con un nuevo tiempo aleatorio
		timer_ataque.start(randf_range(2.0, 4.0))

func _disparar_error() -> void:
	if sprite.animation == "anim_dead": return 
	
	sprite.play("anim_laser")
	var instancia = proyectil_escena.instantiate()
	instancia.global_position = marker_disparo.global_position
	
	var dir_recta = Vector2(direccion, 0)
	instancia.direccion = dir_recta
	instancia.rotation = dir_recta.angle()
	
	get_tree().current_scene.add_child(instancia)

# ============================================================================
# DAÑO Y MUERTE
# ============================================================================

func _on_sensor_pisoton_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador") and body.global_position.y < global_position.y - 6.0:
		timer_recuperacion.stop()
		body.velocity.y += impulso_salto
		
		if vida <= 1:
			_morir(body)
		else:
			vida -= 1
			sprite.modulate = Color.RED
			await get_tree().create_timer(0.2).timeout
			sprite.modulate = Color.WHITE

func _morir(jugador: Node2D) -> void:
	set_physics_process(false)
	collision_monitor.set_deferred("disabled", true)
	timer_ataque.stop()
	
	audio_muerte.play()
	particulas_monitor.emitting = true
	sprite.play("anim_dead")
	
	if jugador.has_method("ganar_puntos"):
		jugador.ganar_puntos(monedas * base_vida)
	
	timer_muerte.start()

func _on_timer_muerte_timeout() -> void:
	queue_free()
