extends Area2D
class_name LaserArana

@export var velocidad: float = 400.0
@export var damage: int = 1

var direccion: Vector2 = Vector2.ZERO

@onready var timer_vida: Timer = $TimerVida if has_node("TimerVida") else null

func _ready() -> void:
	add_to_group("DMG")
	
	if timer_vida:
		timer_vida.start(3.0)
	else:
		await get_tree().create_timer(3.0).timeout
		queue_free()

func _physics_process(delta: float) -> void:
	global_position += direccion * velocidad * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemigos"):
		return # No hacerse daño entre enemigos
		
	if body.is_in_group("Jugador"):
		if body.has_method("recibir_dmg"):
			body.recibir_dmg(damage)
		queue_free()
	else:
		queue_free()

func _on_timer_vida_timeout() -> void:
	queue_free()
