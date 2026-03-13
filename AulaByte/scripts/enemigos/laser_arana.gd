extends Area2D
class_name LaserArana

@export var velocidad: float = 400.0
@export var damage: int = 1

var direccion: Vector2 = Vector2.ZERO

@onready var timer_vida: Timer = $TimerVida if has_node("TimerVida") else null

func _ready() -> void:
	add_to_group("DMG")
	
	# Autodestruirse tras 3 segundos para no sobrecargar la memoria
	if timer_vida:
		timer_vida.start(3.0)
	else:
		# Si no agregaron el nodo Timer, se hace por código
		await get_tree().create_timer(3.0).timeout
		queue_free()

func _physics_process(delta: float) -> void:
	# Movimiento del láser en la dirección en la que fue disparado
	global_position += direccion * velocidad * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemigos"):
		return # No hacerse daño entre enemigos
		
	# Si choca con el jugador, le hace daño, si le da a una pared u objeto sólido que no sea el jugador o las plataformas *one_way* se destruye
	if body.is_in_group("Jugador"):
		if body.has_method("recibir_dmg"):
			body.recibir_dmg(damage)
		queue_free()
	else:
		# Asumimos que chocó contra geometría o un escudo
		queue_free()

func _on_timer_vida_timeout() -> void:
	queue_free()
