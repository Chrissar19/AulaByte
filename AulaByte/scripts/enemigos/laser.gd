extends Area2D
class_name DisparoLaser

@export var velocidad: float = 500.0 # Más rápido que el monitor
@export var danio: int = 1       
var direccion: Vector2 = Vector2.RIGHT

func _ready() -> void:
	add_to_group("DMG")
	# Efecto visual: el láser nace pequeño y se estira
	scale.x = 0.1
	var tween = create_tween()
	tween.tween_property(self, "scale:x", 1.0, 0.1)

func _process(delta: float) -> void:
	global_position += direccion * velocidad * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		if body.has_method("recibir_golpe_desde"):
			body.recibir_golpe_desde(global_position, danio)
		queue_free()
	
	elif body.is_in_group("Suelo") or body is TileMap:
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
