extends CharacterBody2D

@export var vel := 30.0
@export var grav := 400.0
@export var daño := 1

var dir := 1

@onready var ray_pared: RayCast2D = $RayPared
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var timer_muerte: Timer = $TimerMuerte
@onready var colision_slime: CollisionShape2D = $ColisionSlime

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
		if body.global_position.y < global_position.y - 10:
			body.ganar_puntos(3)
			#-- Detener movimiento y reproducir animacion muerte
			set_physics_process(false)
			sprite.play("slime_death_blue")
			timer_muerte.start(0.4)
		else:
			body.recibir_dmg()
			
func _on_detector_jugador_body_entered(body):
	if body.is_in_group("Jugador"):
		if body.global_position.y >= global_position.y - 12:
			body.recibir_dmg()
			
func _on_timer_muerte_timeout():
	queue_free()
