extends Area2D
class_name Proyectil

@export var velocidad: float = 250.0
var direccion: Vector2 = Vector2.RIGHT
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	# Fundamental: el jugador busca proyectiles en este grupo
	add_to_group("DMG")

func _process(delta: float) -> void:
	global_position += direccion * velocidad * delta

# Se activa al tocar el CUERPO del jugador (CharacterBody2D)
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		# Cambiamos "recibir_danio" por la función real de tu jugador
		if body.has_method("recibir_golpe_desde"):
			body.recibir_golpe_desde(global_position, 1)
		
		# Se destruye al tocar al jugador
		queue_free()
	
	# Si toca el suelo o paredes (TileMap/Cajas)
	elif body.is_in_group("Suelo") or body.is_in_group("Pisos") or body is TileMap:
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
