extends Area2D

# ============================================================================
# REFERENCIAS DE NODOS
# ============================================================================
@onready var sonido_muerte: AudioStreamPlayer = $SonidoMuerte
@onready var timer: Timer = $Timer

# ============================================================================
# READY
# ============================================================================
func _ready() -> void:
	add_to_group("ZonaMortal")

# ============================================================================
# COLISIÓN CON JUGADOR
# ============================================================================
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		sonido_muerte.play()
		print("⚠️ El jugador cayó en zona mortal.")
		
		Engine.time_scale = 0.5

		var colision = body.get_node_or_null("CollisionShape2D")
		if colision:
			colision.queue_free()

		timer.start()

# ============================================================================
# REINICIAR ESCENA
# ============================================================================
func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()
