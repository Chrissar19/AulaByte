extends CharacterBody2D

@export var vel := 30.0
@export var grav := 400.0
@export var daño := 1
@export var impulso := -250.0
@export var impulso_daño := 900.0
@export var monedas := 3

var dir := 1

@onready var ray_pared: RayCast2D = $RayPared
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var timer_muerte: Timer = $TimerMuerte
@onready var colision_slime: CollisionShape2D = $ColisionSlime
@onready var audio_muerte: AudioStreamPlayer2D = $SensorPisoton/AudioMuerte
@onready var audio_caminar: AudioStreamPlayer2D = $AudioCaminar
@onready var timer_caminar: Timer = $TimerCaminar

func _ready() -> void:
	add_to_group("Enemigos")
	sprite.play("slime_walk_blue")
	
func _physics_process(delta: float) -> void:
	#-- Aplicar gravedad
	if not is_on_floor():
		velocity.y += grav * delta
	else:
		velocity.y = 0
	#-- Movimiento Horizontal
	velocity.x = dir * vel
	
	#-- cambia direccion si toca pared
	ray_pared.force_raycast_update()
	if ray_pared.is_colliding():
		dir *= -1
		sprite.flip_h = dir < 0
		_actualizar_raycast()
	
	move_and_slide()

func _actualizar_raycast():
	#-- Cambia la direccion del reycast segun donde mire el slime
	ray_pared.target_position.x = abs(ray_pared.target_position.x) * dir

# Si el jugador cae encima del slime, muere. Si no, hace daño.
func _on_sensor_pisoton_body_entered(body):
	if body.is_in_group("Jugador"):
		if body.global_position.y < global_position.y:
			body.ganar_puntos(monedas)
			body.velocity.y += impulso
			#-- Detener movimiento y reproducir animacion muerte
			set_physics_process(false)
			sprite.play("slime_death_blue")
			audio_caminar.stop()
			audio_muerte.play()
			timer_muerte.start(0.4)
			
func _on_detector_jugador_body_entered(body):
	if body.is_in_group("Jugador"):
		#-- calcular direccion del retroceso (opuesta a la posicion del slime)
		var dir_retroceso = sign(body.global_position.x - global_position.x)
		body.recibir_dmg()
			
func _on_timer_muerte_timeout():
	queue_free()
	
func _on_timer_caminar_timeout():
	audio_caminar.play()
