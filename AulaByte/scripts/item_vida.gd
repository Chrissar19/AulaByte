# ====================================================================
# OBJETO INTERACTUABLE: ÍTEM DE VIDA
# ====================================================================
## Coleccionable que incrementa la salud del jugador si no ha llegado al máximo.
extends Area2D

# ====================================================================
# NODOS
# ====================================================================
@onready var reproductor_audio: AudioStreamPlayer = $AudioStreamPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var colision: CollisionShape2D = $CollisionShape2D

# ====================================================================
# INICIALIZACIÓN Y CONFIGURACIÓN
# ====================================================================
func _ready() -> void:
	z_index = ZCapas.ITEMS
	# Usamos la sintaxis moderna de señales de Godot 4
	body_entered.connect(_on_cuerpo_entrado)

# ====================================================================
# LÓGICA DE INTERACCIÓN
# ====================================================================
## Detecta si el jugador entra en el área y gestiona la curación.
func _on_cuerpo_entrado(cuerpo: Node2D) -> void:
	if cuerpo.is_in_group("Jugador"):
		if GameManager.obtener_vidas() < GameManager.VIDAS_MAXIMAS:
			_recolectar_item()
		else:
			print("Salud al máximo. Ítem no recolectado.")

func _recolectar_item() -> void:
	# Ejecuta la lógica en el GameManager
	GameManager.ganar_vida()
	# Feedback visual y sonoro
	reproductor_audio.play()
	sprite.hide()
	# Desactiva la colisión de forma diferida para evitar errores de física
	colision.set_deferred("disabled", true)
	# Esperam a que el sonido termine antes de eliminar el nodo
	await reproductor_audio.finished
	queue_free()
