extends Area2D
class_name Proyectil

@export var velocidad: float = 250.0
var direccion: Vector2 = Vector2.RIGHT
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	add_to_group("DMG")

func _process(delta: float) -> void:
	global_position += direccion * velocidad * delta

func _on_body_entered(body: Node2D) -> void:
	# Si toca al jugador, le causa daño y desaparece
	if body.is_in_group("Jugador"):
		if body.has_method("recibir_golpe_desde"):
			body.recibir_golpe_desde(global_position, 1)
		queue_free()
	
	else:
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
