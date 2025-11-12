extends CharacterBody2D

# ============================================================================
# EXPORTS
# ============================================================================
@export var velocidad: float = 30.0
@export var gravedad: float = 400.0
@export var impulso_salto: float = -250.0
@export var impulso_impacto: float = 900.0
@export var monedas: int = 3

# ============================================================================
# VARIABLES
# ============================================================================
var direccion: int = 1

# ============================================================================
# NODOS
# ============================================================================
@onready var ray_pared: RayCast2D = $RayPared
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var timer_muerte: Timer = $TimerMuerte
@onready var colision_slime: CollisionShape2D = $ColisionSlime
@onready var audio_muerte: AudioStreamPlayer2D = $SensorPisoton/AudioMuerte
@onready var particulas: CPUParticles2D = $ParticulasSlime
@onready var area_daño: Area2D = $AreaDaño

# ============================================================================
# READY
# ============================================================================
func _ready() -> void:
    add_to_group("Enemigos")
    area_daño.add_to_group("DMG")
    sprite.play("slime_walk_blue")

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
    ray_pared.force_raycast_update()
    if ray_pared.is_colliding():
        direccion *= -1
        sprite.flip_h = direccion < 0
        _actualizar_raycast()

    move_and_slide()

# ============================================================================
# ACTUALIZAR RAYCAST SEGÚN DIRECCIÓN
# ============================================================================
func _actualizar_raycast() -> void:
    ray_pared.target_position.x = abs(ray_pared.target_position.x) * direccion

# ============================================================================
# SENSOR DE PISOTÓN
# ============================================================================
func _on_sensor_pisoton_body_entered(body: Node2D) -> void:
    if body.is_in_group("Jugador"):
        if body.global_position.y < global_position.y - 6.0:
            body.ganar_puntos(monedas)
            body.velocity.y += impulso_salto

            set_physics_process(false)
            sprite.play("slime_death_blue")
            audio_muerte.play()
            particulas.emitting = true
            timer_muerte.start(0.4)

# ============================================================================
# DESAPARECER AL MORIR
# ============================================================================
func _on_timer_muerte_timeout() -> void:
    queue_free()


func _on_sensor_pisoton_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
    if is_in_group("Cajas") and is_in_group("Pisos"):
        set_physics_process(false)
        sprite.play("slime_death_blue")
        audio_muerte.play()
        particulas.emitting = true
        queue_free()
