extends EnemigoBase

# ============================================================================
# EXPORTS Y CONSTANTES DEL MONITOR
# ============================================================================
@export var velocidad_patrulla: float = 30.0
@export var velocidad_persecucion: float = 60.0
@export var proyectil_escena: PackedScene = preload("res://escenas/personajes/enemigos/proyectil.tscn")

enum Estado { PATRULLAR, PERSEGUIR }
var estado_actual = Estado.PATRULLAR
var jugador_objetivo: Node2D = null

# ============================================================================
# NODOS ESPECÍFICOS DEL MONITOR
# ============================================================================
@onready var area_vision: Area2D = $AreaVision
@onready var timer_ataque: Timer = $TimerAtaque
@onready var marker_disparo: Marker2D = $PuntoDisparo

# ============================================================================
# INICIALIZACIÓN Y ANIMACIONES
# ============================================================================
func _inicializar_enemigo() -> void:
	velocidad = velocidad_patrulla

func _process(_delta: float) -> void:
	_actualizar_animaciones()

func _actualizar_animaciones() -> void:
	if esta_muerto or not sprite:
		return
		
	if sprite.animation == "anim_laser" and sprite.is_playing():
		return

	if velocity.x != 0:
		if sprite.animation != "anim_walk":
			sprite.play("anim_walk")
	else:
		if sprite.has_animation("anim_idle"):
			sprite.play("anim_idle")
		else:
			sprite.stop()

# ============================================================================
# SOBREESCRITURA DE FÍSICAS (HERENCIA)
# ============================================================================
func _manejar_movimiento() -> void:
	if estado_actual == Estado.PATRULLAR:
		velocity.x = direccion * velocidad_patrulla
	elif estado_actual == Estado.PERSEGUIR and jugador_objetivo:
		var dir_hacia_jugador = sign(jugador_objetivo.global_position.x - global_position.x)
		
		# Si el jugador está detrás gira
		if dir_hacia_jugador != direccion and dir_hacia_jugador != 0:
			_girar()
		velocity.x = direccion * velocidad_persecucion
		
		# Frenar en precipicios para no arrojarse persiguiendo al jugador
		if ray_suelo and is_on_floor() and not ray_suelo.is_colliding():
			velocity.x = 0

func _actualizar_raycast() -> void:
	super._actualizar_raycast() # Llama al giro de los RayCasts en EnemigoBase
	
	if area_vision:
		area_vision.scale.x = direccion
	if marker_disparo:
		marker_disparo.position.x = abs(marker_disparo.position.x) * direccion

func _morir(jugador: Node2D) -> void:
	if timer_ataque:
		timer_ataque.stop()
	super._morir(jugador)

# ============================================================================
# COMBATE Y VISIÓN (ESPECÍFICO DEL MONITOR)
# ============================================================================
func _on_area_vision_body_entered(body: Node2D) -> void:
	if esta_muerto: return
	
	if body.is_in_group("Jugador"):
		jugador_objetivo = body
		estado_actual = Estado.PERSEGUIR
		if timer_ataque:
			timer_ataque.start(randf_range(3.0, 4.0))

func _on_area_vision_body_exited(body: Node2D) -> void:
	if body == jugador_objetivo:
		jugador_objetivo = null
		estado_actual = Estado.PATRULLAR
		if timer_ataque:
			timer_ataque.stop()

func _on_timer_ataque_timeout() -> void:
	if esta_muerto: return
	
	# Solo dispara si el objetivo sigue dentro y el estado es PERSEGUIR
	if jugador_objetivo and estado_actual == Estado.PERSEGUIR:
		_disparar_error()
		timer_ataque.start(randf_range(2.0, 4.0))

func _disparar_error() -> void:
	if esta_muerto or not sprite: return 
	
	sprite.play("anim_laser")
	if proyectil_escena and marker_disparo:
		var instancia = proyectil_escena.instantiate()
		instancia.global_position = marker_disparo.global_position
		var dir_recta = Vector2(direccion, 0)
		instancia.set("direccion", dir_recta)
		instancia.rotation = dir_recta.angle()
		get_tree().current_scene.add_child(instancia)
