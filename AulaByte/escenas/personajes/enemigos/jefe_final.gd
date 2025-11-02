extends CharacterBody2D
# ============================================================================
# EXPORTS
# ============================================================================

@export var monedas: int = 100
@export var velocidad: float = 30.0
@export var gravedad: float = 400.0
@export var impulso_salto: float = -700.0
@export var impulso_impacto: float = 900.0
@export var distancia_deteccion_borde: float = 32.0

# ============================================================================
# VARIABLES
# ============================================================================
var vida: int = 4
var direccion: int = 1
var base_vida: int = vida

# ============================================================================
# NODOS
# ============================================================================
@onready var area_daño: Area2D = $AreaDaño
@onready var ray_pared: RayCast2D = $RayPared
@onready var ray_suelo: RayCast2D = $RaySuelo
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var timer_muerte: Timer = $TimerMuerte
@onready var particulas_jefe: CPUParticles2D = $ParticulasJefe
@onready var collision_monitor: CollisionShape2D = $CollisionMonitor
@onready var audio_muerte: AudioStreamPlayer2D = $SensorPisoton/AudioMuerte

# ============================================================================
# READY
# ============================================================================
func _ready() -> void:
	print("prinrrr")
	add_to_group("Enemigos")
	area_daño.add_to_group("DMG")
	sprite.play("animacion_monitor")
	cofigurar_ray_suelo()

# ============================================================================
# RAY SUELO
# ============================================================================
func cofigurar_ray_suelo() -> void:
	if ray_suelo:
		ray_suelo.enabled = true
		ray_suelo.collision_mask = 1
		ray_suelo.target_position = Vector2(distancia_deteccion_borde * direccion, 32.0)

# ============================================================================
# PROCESO FÍSICO
# ============================================================================
func _physics_process(delta: float) -> void:
	# Aplicar gravedad
	if not is_on_floor():
		velocity.y += gravedad * delta
	else:
		velocity.y = 0

	# Movimiento horizontal
	velocity.x = direccion * velocidad

	# Cambio de dirección al detectar pared
	var cambio_direccion = false
	ray_pared.force_raycast_update()
	if ray_pared.is_colliding():
		cambio_direccion = true
	
	if ray_suelo:
		ray_suelo.force_raycast_update()
		
		if is_on_floor() and not cambio_direccion and not ray_suelo.is_colliding():
			cambio_direccion = true

	if cambio_direccion:
		direccion *= -1
		sprite.flip_h = direccion < 0
		_actualizar_raycast()
		
	move_and_slide()

# ============================================================================
# ACTUALIZAR RAYCAST SEGÚN DIRECCIÓN
# ============================================================================
func _actualizar_raycast() -> void:
	ray_pared.target_position.x = abs(ray_pared.target_position.x) * direccion
	 
	if ray_suelo:
		ray_suelo.target_position.x = distancia_deteccion_borde * direccion

# ============================================================================
# DESAPARECER AL MORIR
# ============================================================================
func _on_timer_muerte_timeout() -> void:
	queue_free()

func _on_timer_recuperacion_timeout() -> void:
	vida = base_vida

func _on_sensor_pisoton_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("Cajas"):
		body.retornar_a_posicion_inicial()
		
		if vida <= 1:
			set_physics_process(false)
			audio_muerte.play()
			timer_muerte.start(0.4)
			particulas_jefe.emitting = true
			sprite.play("slime_death_blue")
		else:
			vida = vida - 1
