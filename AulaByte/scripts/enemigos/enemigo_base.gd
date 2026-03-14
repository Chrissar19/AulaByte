extends CharacterBody2D
class_name EnemigoBase

# ============================================================================
# EXPORTS GLOBALES (disponibles para todos los hijos)
# ============================================================================
@export var vida_maxima: int = 1
@export var monedas: int = 3
@export var velocidad: float = 30.0
@export var gravedad: float = 400.0
@export var impulso_salto: float = -250.0
@export var impulso_impacto: float = 900.0
@export var distancia_deteccion_borde: float = 32.0

# ============================================================================
# VARIABLES DE ESTADO
# ============================================================================
@onready var vida: int = vida_maxima
@onready var base_vida: int = vida_maxima
var direccion: int = 1
var esta_muerto: bool = false
var puede_girar: bool = true

# ============================================================================
# REFERENCIAS A NODOS
# (Se asignan si existen en la escena hija, con tolerancia a fallos)
# ============================================================================
@onready var ray_pared: RayCast2D = $RayPared if has_node("RayPared") else null
@onready var ray_suelo: RayCast2D = $RaySuelo if has_node("RaySuelo") else null
@onready var sprite: AnimatedSprite2D = $Sprite if has_node("Sprite") else null
@onready var timer_muerte: Timer = $TimerMuerte if has_node("TimerMuerte") else null
@onready var timer_recuperacion: Timer = $TimerRecuperacion if has_node("TimerRecuperacion") else null
@onready var area_daño: Area2D = $AreaDaño if has_node("AreaDaño") else null
@onready var audio_muerte: AudioStreamPlayer2D = $SensorPisoton/AudioMuerte if has_node("SensorPisoton/AudioMuerte") else null

# Intentamos detectar cualquier sistema de partículas que tenga el hijo
@onready var particulas: CPUParticles2D = _buscar_particulas()

# ============================================================================
# INICIALIZACIÓN
# ============================================================================
func _ready() -> void:
	add_to_group("Enemigos")
	
	if "ZCapas" in get_tree().root:
		pass
	
	if area_daño:
		area_daño.add_to_group("DMG")
		
	# Evitamos que el enemigo colisione consigo mismo
	if ray_pared:
		ray_pared.add_exception(self)
	if ray_suelo:
		ray_suelo.add_exception(self)
		
	configurar_ray_suelo()
	_inicializar_enemigo()

# Función virtual para que los hijos sobrescriban si requieren inicialización extra
func _inicializar_enemigo() -> void:
	pass

func configurar_ray_suelo() -> void:
	if ray_suelo:
		ray_suelo.enabled = true
		ray_suelo.collision_mask = 1 # Capa Mundo
		ray_suelo.target_position = Vector2(distancia_deteccion_borde * direccion, 32.0)

# ============================================================================
# FÍSICAS Y MOVIMIENTO
# ============================================================================
func _physics_process(delta: float) -> void:
	if esta_muerto:
		return
		
	_aplicar_gravedad(delta)
	_manejar_movimiento()
	_verificar_colisiones()
	
	move_and_slide()

func _aplicar_gravedad(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravedad * delta
	else:
		velocity.y = 0

func _manejar_movimiento() -> void:
	velocity.x = direccion * velocidad

func _verificar_colisiones() -> void:
	if not puede_girar:
		return
		
	var cambio_direccion = false
	
	if ray_pared:
		ray_pared.force_raycast_update()
		if ray_pared.is_colliding():
			cambio_direccion = true
			
	if is_on_wall():
		cambio_direccion = true
	
	if ray_suelo:
		ray_suelo.force_raycast_update()
		if is_on_floor() and not cambio_direccion and not ray_suelo.is_colliding():
			cambio_direccion = true

	if cambio_direccion:
		_girar()

func _girar() -> void:
	direccion *= -1
	if sprite:
		sprite.flip_h = direccion < 0
	_actualizar_raycast()
	
	# Evita que el enemigo intente girar repetidamente en el mismo frame (corrige el temblor paralizante)
	puede_girar = false
	await get_tree().create_timer(0.2).timeout
	puede_girar = true

func _actualizar_raycast() -> void:
	if ray_pared:
		ray_pared.target_position.x = abs(ray_pared.target_position.x) * direccion
	if ray_suelo:
		ray_suelo.target_position.x = distancia_deteccion_borde * direccion
		# El origen del rayo también debe moverse al lado opuesto del enemigo al girar
		ray_suelo.position.x = abs(ray_suelo.position.x) * direccion

# ============================================================================
# COMBATE Y MUERTE
# ============================================================================
func _on_sensor_pisoton_body_entered(body: Node2D) -> void:
	if esta_muerto: return
	
	# Verifica si el que entró es el jugador y lo pisa desde arriba
	if body.is_in_group("Jugador") and body.global_position.y < global_position.y - 6.0:
		if timer_recuperacion:
			timer_recuperacion.stop()
			
		# Impulsa al jugador (rebote sobre el enemigo)
		if body.has_method("salto"):
			body.salto()
			if body.has_method("cambiar_estado"):
				body.cambiar_estado("saltar")
		elif "velocity" in body:
			body.velocity.y = impulso_salto
			
		if vida <= 1:
			_morir(body)
		else:
			_recibir_dano()

func _recibir_dano() -> void:
	vida -= 1
	if timer_recuperacion:
		timer_recuperacion.start(20)
		
	# Efecto visual de daño (tiñe el sprite de rojo por 0.15 segundos)
	if sprite:
		var color_original = sprite.modulate
		sprite.modulate = Color.RED
		await get_tree().create_timer(0.15).timeout
		if is_instance_valid(sprite): # Precaución por si muere/desaparece en ese lapso
			sprite.modulate = color_original

func _morir(jugador: Node2D) -> void:
	esta_muerto = true
	set_physics_process(false)
	
	# Desactivamos sus capas de colisión para que el jugador lo atraviese y no "flote" en él
	collision_layer = 0
	collision_mask = 0
	
	# Desactivar daños y pisotones póstumos
	if area_daño:
		area_daño.set_deferred("monitoring", false)
		area_daño.set_deferred("monitorable", false)
		if area_daño.is_in_group("DMG"):
			area_daño.remove_from_group("DMG")
			
	if has_node("SensorPisoton"):
		$SensorPisoton.set_deferred("monitoring", false)
		$SensorPisoton.set_deferred("monitorable", false)
	
	if audio_muerte:
		audio_muerte.play()
	if particulas:
		particulas.emitting = true
		
	# Si el hijo configuró animaciones de muerte
	if sprite and sprite.sprite_frames:
		if sprite.sprite_frames.has_animation("anim_dead"):
			sprite.play("anim_dead")
		elif sprite.sprite_frames.has_animation("death"):
			sprite.play("death")
			
	if jugador.has_method("ganar_puntos"):
		jugador.ganar_puntos(monedas * base_vida)
		
	if timer_muerte:
		timer_muerte.start(0.4)
	else:
		# Si la escena no tiene Timer de muerte, eliminamos automáticamente
		await get_tree().create_timer(0.4).timeout
		queue_free()

func _on_timer_muerte_timeout() -> void:
	queue_free()

func _on_timer_recuperacion_timeout() -> void:
	vida = base_vida

# ============================================================================
# UTILIDADES
# ============================================================================
func _buscar_particulas() -> CPUParticles2D:
	for hijo in get_children():
		if hijo is CPUParticles2D:
			return hijo
	return null
