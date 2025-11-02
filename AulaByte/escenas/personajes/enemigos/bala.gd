extends CharacterBody2D
class_name Bala

@export var imagen: Texture2D
@export var gravedad: float = 0.0
@export var tiempo_vida: float = 6.0
@export var velocidad: float = 1000.0
@export var rotacion_grados: float = 0.0

var direccion: Vector2 = Vector2.RIGHT
var tiempo_transcurrido: float = 0.0

@onready var imagen_bala: TextureRect = $imagen_bala
@onready var collision_monitor: CollisionShape2D = $Area2D/CollisionMonitor

func _ready() -> void:
	if imagen_bala and imagen:
		imagen_bala.texture = imagen
		imagen_bala.size = imagen.get_size()
	
	rotation_degrees = rotacion_grados
	direccion = Vector2.RIGHT.rotated(deg_to_rad(rotacion_grados))
	if collision_monitor:
		collision_monitor.disabled = false


func configurar(imagen_nueva: Texture2D, rotacion: float, vel: float, duracion: float) -> void:
	if imagen_bala and imagen_nueva:
		imagen_bala.texture = imagen_nueva
		imagen_bala.size = imagen_nueva.get_size()
	
	rotacion_grados = rotacion
	rotation_degrees = rotacion
	direccion = Vector2.RIGHT.rotated(deg_to_rad(rotacion))
	velocidad = vel
	tiempo_vida = duracion


func _physics_process(delta: float) -> void:
	tiempo_transcurrido += delta
	if tiempo_transcurrido >= tiempo_vida:
		queue_free()
		return
		
	if gravedad != 0.0:
		velocity.y += gravedad * delta
	
	velocity = direccion * velocidad * delta
	var collision = move_and_collide(velocity)
	if collision:
		_destruir_bala()

func _destruir_bala() -> void:
	queue_free()
