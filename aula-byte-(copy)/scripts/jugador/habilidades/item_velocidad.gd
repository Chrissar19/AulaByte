#-- ItemVelocidad
extends Area2D

class_name ItemVelocidad

@export var duracion_power_up: float = 15.0
@export var potencia_velocidad: float = 2.0

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Jugador"):
		return
	
	GameManager.aplicar_powerup_velocidad(duracion_power_up, potencia_velocidad)
	
	audio_stream_player.play()
	sprite_2d.hide()
	$CollisionShape2D.set_deferred("disabled", true)
	
	await audio_stream_player.finished
	queue_free()
