extends CharacterBody2D

# ============================================================================
# SEÑALES
# ============================================================================
signal ondead

# ============================================================================
# EXPORTS
# ============================================================================
@export var vida: int = 4
@export var monedas: int = 100
@export var imagen_bala: Texture2D
@export var velocidad: float = 30.0
@export var gravedad: float = 400.0
@export var duracion_bala: float = 6.0
@export var impulso_salto: float = -700.0
@export var velocidad_bala: float = 800.0
@export var impulso_impacto: float = 900.0
@export var tiempo_entre_disparos: float = 4.0
@export var distancia_deteccion_borde: float = 32.0

# ============================================================================
# VARIABLES
# ============================================================================
var direccion: int = 1
var is_dead: bool = false
var base_vida: int = vida
var tiempo_disparo: float = 0.0
var current_angle: float = -180
var animations = ["3", "2", "1", "0"]

const BALA = preload("uid://bgrl2h1flcnql")

# ============================================================================
# NODOS
# ============================================================================
@onready var area_daño: Area2D = $AreaDaño
@onready var ray_pared: RayCast2D = $RayPared
@onready var ray_suelo: RayCast2D = $RaySuelo
@onready var timer_muerte: Timer = $TimerMuerte
@onready var collision_monitor: CollisionShape2D = $CollisionMonitor
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var particulas_jefe_final: CPUParticles2D = $ParticulasJefeFinal
@onready var audio_muerte: AudioStreamPlayer2D = $SensorPisoton/AudioMuerte
@onready var sensor_colision: CollisionShape2D = $SensorPisoton/SensorColision

# ============================================================================
# READY
# ============================================================================
func _ready() -> void:
	add_to_group("Enemigos")
	
	var animation = animations[(vida - 1)]
	if animation:
		animated_sprite_2d.play(animation)
		
	area_daño.add_to_group("DMG")
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
	if not is_on_floor():
		velocity.y += gravedad * delta
	else:
		velocity.y = 0

	velocity.x = direccion * velocidad

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
		animated_sprite_2d.flip_h = direccion < 0
		_actualizar_raycast()
		
	tiempo_disparo += delta
	if tiempo_disparo >= tiempo_entre_disparos:
		disparar_en_todas_direcciones()
		tiempo_disparo = 0.0
		
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

# ============================================================================
# DISPARO
# ============================================================================
func disparar(rotacion: float) -> void:
	var nueva_bala = BALA.instantiate() as Bala
	var offset := Vector2.RIGHT.rotated(deg_to_rad(rotacion)) * 40
	offset.y += 10
	nueva_bala.global_position = global_position + offset
	
	nueva_bala.imagen = imagen_bala
	nueva_bala.rotacion_grados = rotacion
	nueva_bala.velocidad = velocidad_bala
	nueva_bala.tiempo_vida = duracion_bala
	nueva_bala.img_scale = Vector2(0.8, 0.8)
	nueva_bala.configurar(imagen_bala, rotacion, velocidad_bala, duracion_bala)
	
	get_parent().add_child(nueva_bala)
	
func disparar_en_todas_direcciones() -> void:
	if vida > 1:
		disparar(current_angle)
		if current_angle > 30:
			current_angle = -180
		else:
			current_angle += 30
		return
	
	for i in range(9):
		var angulo = -i * 30.0
		disparar(angulo)

# ============================================================================
# SENSOR DE PISOTÓN
# ============================================================================
func _on_sensor_pisoton_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if is_dead:
		return
		
	if body.is_in_group("Cajas"):
		body.retornar_a_posicion_inicial()
		
		if vida <= 1:
			is_dead = true
			audio_muerte.play()
			timer_muerte.start(0.4)
			set_physics_process(false)
			sensor_colision.disabled = true
			animated_sprite_2d.visible = false
			particulas_jefe_final.emitting = true
			
			animated_sprite_2d.play("4")
			emit_signal("ondead")

		else:
			vida -= 1
			tiempo_entre_disparos -= 1
			var animation = animations[(vida -1)]
			
			if animation:
				animated_sprite_2d.play(animation)

# ============================================================================
# ÁREA DE DAÑO
# ============================================================================
func _on_area_daño_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("Cajas"):
		body.retornar_a_posicion_inicial()
