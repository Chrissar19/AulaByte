extends Area2D

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	connect("body_entered", _on_nodo_vida)

func _on_nodo_vida(nodo: Node2D) -> void:
	if nodo.is_in_group("Jugador"):
		if GameManager.get_vidas() < GameManager.VIDAS_MAX:
			GameManager.ganar_vida()
			audio_stream_player.play()
			sprite_2d.hide()
			$CollisionShape2D.set_deferred("disabled", true)
			await $AudioStreamPlayer.finished
			queue_free()
		else:
			print("MAXIMO DE VIDAS")
